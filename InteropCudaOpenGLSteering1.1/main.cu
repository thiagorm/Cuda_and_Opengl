#include <GLTools.h>
#include <stdlib.h>
#include <conio.h>
#include <time.h>

#ifdef __APPLE__
#include <glut/glut.h>
#else
#define FREEGLUT_STATIC
#include <GL\glut.h>
#endif

#define GL_GLEXT_PROTOTYPES 
#include  "cuda.h" 
#include  "cuda_gl_interop.h" 
#include  "common/book.h" 
#include "common/gl_helper.h"
#include "common/GL/glext.h"

#include "Vector3D.cu"
#include "AgentProperty.cu"

#define QUADS_LENTH 12
//Mudar a quantidade de agentes na tela
#define QTDE_AGENT 500


AgentProperty agents[QTDE_AGENT];

//AgentProperty agent(Vector3D(0.0, 0.0, 0.0), Vector3D(0.0, 0.0, 0.0));
AgentProperty target(Vector3D(0.05, 0.05, 0.0), Vector3D(0.0, 0.0, 0.0));
//AgentProperty steering;

float verticeLenth = 0.05;

float vVertsTarget[QUADS_LENTH]; 
float vVertsAgent[QUADS_LENTH]; 

float *vertsAgent;

float xstep = 0.02;
float ystep = 0.02;
float stepSize = 0.025f;

float wh = 1, ww = 1;


GLuint idVBOAgent[1];
GLuint idVBOTarget;
cudaGraphicsResource *resource;

float *devPtr;
size_t size;

GLint first[QTDE_AGENT];
GLint count[QTDE_AGENT];


AgentProperty *dev_vector;

__device__ float length(float x, float y, float z)
	{
		return sqrtf(x*x + y*y + z*z);
	}

__device__ float3 Vec3DNormalize(float3 v)
{
	float3 vec;

	float vector_length = length(v.x,v.y,v.z);

	vec.x = v.x / vector_length;
	vec.y = v.y / vector_length;
	vec.z = v.z / vector_length;

	return vec;
}

__device__ float3 calculate_steering(float3 target, float3 agentPosition)
{
	float3 desired_velocity;
	float3 sub;

	sub.x = target.x - agentPosition.x;
	sub.y = target.y - agentPosition.y;
	sub.z = target.z - agentPosition.z;

	desired_velocity = Vec3DNormalize(sub);
	desired_velocity.x *= MAX_SPEED;
	desired_velocity.y *= MAX_SPEED;
	desired_velocity.z *= MAX_SPEED;
	return (desired_velocity);
}

__device__ float3 truncVector(float3 vector3, float max)
	{
		if(length(vector3.x, vector3.y, vector3.z) > max)
		{
			vector3 = Vec3DNormalize(vector3);
			vector3.x *= max;
			vector3.y *= max;
			vector3.z *= max;
		}
			
		return vector3;
	}


__global__ void desenha( float *vVerts, AgentProperty *agentPosition) 
{

	int x = blockDim.x * blockIdx.x + threadIdx.x;

	int offset = x;

	float verticeLenth = 0.05;

	vVerts[offset*12 + 0] = agentPosition[offset].position.x;
	vVerts[offset*12 + 1] = agentPosition[offset].position.y;
	vVerts[offset*12 + 2] = agentPosition[offset].position.z;

	vVerts[offset*12 + 3] = (agentPosition[offset].position.x)-verticeLenth;
	vVerts[offset*12 + 4] = agentPosition[offset].position.y;
	vVerts[offset*12 + 5] = agentPosition[offset].position.z;

	vVerts[offset*12 + 6] = agentPosition[offset].position.x;
	vVerts[offset*12 + 7] = agentPosition[offset].position.y-verticeLenth;
	vVerts[offset*12 + 8] = agentPosition[offset].position.z;

	vVerts[offset*12 + 9] = (agentPosition[offset].position.x)-verticeLenth;
	vVerts[offset*12 + 10] = agentPosition[offset].position.y-verticeLenth;
	vVerts[offset*12 + 11] = agentPosition[offset].position.z;

}

__global__ void kernel( float *vVerts, float verticeLenth, float stepSize, Vector3D targetPosition) 
{

	int x = blockDim.x * blockIdx.x + threadIdx.x;

	int offset = x;

	float3 agentPosition;
	float3 tPosition;

	tPosition.x = targetPosition.x;
	tPosition.y = targetPosition.y;
	tPosition.z = targetPosition.z;

	agentPosition.x = -vVerts[offset*12 + 0];
	agentPosition.y = vVerts[offset*12 + 1];
	agentPosition.z = vVerts[offset*12 + 2];

	float3 velocity = calculate_steering(tPosition, agentPosition);
	float3 force = truncVector(velocity, MAX_FORCE);

	float positionX = -vVerts[offset*12 + 0] + force.x * stepSize; 
	float positionY = vVerts[offset*12 + 1] + force.y * stepSize;
	//float positionZ = vVerts[offset*12 + 2] + force.z * stepSize;

	vVerts[offset*12 + 0] = -positionX;
	vVerts[offset*12 + 1] = positionY;
	//vVerts[offset*12 + 2] = positionZ;

	vVerts[offset*12 + 3] = -(positionX-verticeLenth);
	vVerts[offset*12 + 4] = positionY;
	//vVerts[offset*12 + 5] = positionZ;

	vVerts[offset*12 + 6] = -positionX;
	vVerts[offset*12 + 7] = (positionY-verticeLenth);
	//vVerts[offset*12 + 8] = positionZ;

	vVerts[offset*12 + 9] = -(positionX-verticeLenth);
	vVerts[offset*12 + 10] = (positionY-verticeLenth);
	//vVerts[offset*12 + 11] = positionZ;
   
}

void OnReshape(int w, int h)
{
	glViewport(0,0,w,h);
}

void SetAgent(AgentProperty *agents)
{

	//Essa função pega o endereço atual da memoria do device onde está o buffer
	HANDLE_ERROR(cudaGraphicsMapResources(1, &resource, NULL));

	//depois que o endereço eh pego, o mesmo é salvo no ponteiro devPtr
	HANDLE_ERROR(cudaGraphicsResourceGetMappedPointer((void**)&devPtr, &size, resource));


	int div = 2;
	int blocks = QTDE_AGENT/div;
	desenha<<<blocks, div>>>(devPtr, agents);

	HANDLE_ERROR( cudaGraphicsUnmapResources( 1, &resource, NULL ) );
}

void DrawAgent()
{
	//Essa função pega o endereço atual da memoria do device onde está o buffer
	HANDLE_ERROR(cudaGraphicsMapResources(1, &resource, NULL));

	//depois que o endereço eh pego, o mesmo é salvo no ponteiro devPtr
	HANDLE_ERROR(cudaGraphicsResourceGetMappedPointer((void**)&devPtr, &size, resource));


	int div = 2;
	int blocks = QTDE_AGENT/div;
	kernel<<<blocks, div>>>(devPtr, verticeLenth, stepSize, target.position);

	HANDLE_ERROR( cudaGraphicsUnmapResources( 1, &resource, NULL ) );

	glBindBuffer(GL_ARRAY_BUFFER, idVBOAgent[0]);
	glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, 0);

	int size = QTDE_AGENT;
	glEnableClientState(GL_VERTEX_ARRAY);
	glMultiDrawArrays(GL_TRIANGLE_STRIP, first, count, size);
	glDisableClientState(GL_VERTEX_ARRAY);
}

void Init()
{

	glClear(GL_COLOR_BUFFER_BIT);
	glClearColor(0.0f, 0.5f, 1.0f, 1.0f);

	target.AgentMovement(vVertsTarget, target.position, verticeLenth);

	glGenBuffers(QTDE_AGENT, idVBOAgent);
	glGenBuffers(1, &idVBOTarget);

	glBindBuffer(GL_ARRAY_BUFFER, idVBOTarget);
	glBufferData(GL_ARRAY_BUFFER, QUADS_LENTH*sizeof(float), vVertsTarget, GL_DYNAMIC_DRAW);

	glBindBuffer(GL_ARRAY_BUFFER, idVBOAgent[0]);
	int size = (QUADS_LENTH*QTDE_AGENT) * sizeof(float);
	glBufferData(GL_ARRAY_BUFFER, size, 0, GL_DYNAMIC_DRAW);
	glBindBuffer(GL_ARRAY_BUFFER, 0);

	//Essa função serve para atribuir o bufferObj do opengl ao buffer resource do CUDA
	//a partir dessa função o CUDA pode trabalhar com o buffer do opengl
	HANDLE_ERROR(cudaGraphicsGLRegisterBuffer(&resource, idVBOAgent[0], cudaGraphicsMapFlagsWriteDiscard));

	float r1, r2;
	int r;

	cudaMalloc( (void**)&dev_vector, QTDE_AGENT *  sizeof(AgentProperty ) );

	for(int i = 0; i < QTDE_AGENT; i++)
	{
		r = rand()%4 + 1;
		switch(r)
		{
		case 1:
			r1 = (float) rand()/(float)RAND_MAX;
			r2 = (float) rand()/(float)RAND_MAX;
			break;
		case 2:
			r1 = -(float) rand()/(float)RAND_MAX;
			r2 = (float) rand()/(float)RAND_MAX;
			break;
		case 3:
			r1 = (float) rand()/(float)RAND_MAX;
			r2 = -(float) rand()/(float)RAND_MAX;
			break;
		case 4:
			r1 = -(float) rand()/(float)RAND_MAX;
			r2 = -(float) rand()/(float)RAND_MAX;
			break;
		}
		agents[i] = AgentProperty(Vector3D(r1,r2,0.0), Vector3D(0.0,0.0,0.0));
	}

	/*for(int i = 0; i < QTDE_AGENT; i++)
	{
		printf("%d\n", i);
		printf("x: %.2f\n", agents[i].position.x);
		printf("y: %.2f\n", agents[i].position.y);
		printf("z: %.2f\n", agents[i].position.z);
		printf("\n");
	}*/

	cudaMemcpy( dev_vector, agents, QTDE_AGENT * sizeof(AgentProperty ), cudaMemcpyHostToDevice );

	SetAgent(dev_vector);

	for(int j = 0; j < QTDE_AGENT; j++)
	{
		if(j == 0)
			first[j] = 0;
		else
		{
			first[j] = 4*j;
		}

		count[j] = 4;
	}

}

void Render()
{
	glClear(GL_COLOR_BUFFER_BIT);

	glEnableVertexAttribArray(0);

	glBindBuffer(GL_ARRAY_BUFFER, idVBOTarget);
	glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, 0);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

	DrawAgent();

	glutSwapBuffers();

	glutPostRedisplay();
}


static void OnKeyboard(int key, int x, int y)
{

	if(key == GLUT_KEY_UP)
	{
		target.position.y += stepSize;
	}

	if(key == GLUT_KEY_DOWN)
	{
		target.position.y -= stepSize;
	}

	if(key == GLUT_KEY_LEFT)
	{
		target.position.x += stepSize;
	}

	if(key == GLUT_KEY_RIGHT)
	{
		target.position.x -= stepSize;
	}

	if(key == GLUT_KEY_END)
	{
		HANDLE_ERROR( cudaGraphicsUnregisterResource( resource ) );

		glBindBuffer( GL_ARRAY_BUFFER, 0 );
		glDeleteBuffers(QTDE_AGENT, idVBOAgent);

		glBindBuffer( GL_ARRAY_BUFFER, 0 );
		glDeleteBuffers(1, &idVBOTarget);

		cudaFree(dev_vector);

		exit(1);
	}

	target.AgentMovement(vVertsTarget, target.position, verticeLenth);

	glBindBuffer(GL_ARRAY_BUFFER, idVBOTarget);
	glBufferData(GL_ARRAY_BUFFER, QUADS_LENTH*sizeof(float), vVertsTarget, GL_DYNAMIC_DRAW);

	glutPostRedisplay(); 
}

int main(int argc, char *argv[])
{

	srand ( time(NULL) );

	//Método para escolher uma das GPU's se o sistema tiver mais de uma, que tiver 
	//um poder computacional de 1.0 ou melhor
	cudaDeviceProp  deviceProp;
	int dev = NULL;

	memset(&deviceProp, 0, sizeof(cudaDeviceProp));
	deviceProp.major = 1;
	deviceProp.minor = 0;

	HANDLE_ERROR(cudaChooseDevice(&dev, &deviceProp));

	//Indicar qual é o device(Gpu) que vai ser utilizado para o trabalho de interoperabilidade
	//Essa função é obrigatoria, quando se for usar a interoperabilidade entre OPENGL e CUDA
	HANDLE_ERROR(cudaGLSetGLDevice(dev));

	//Inicializando o Opengl
	glutInit(&argc, argv);
	glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA);
	glutInitWindowSize(800, 600);
	glutCreateWindow("Square");

	//Loop
	glutReshapeFunc(OnReshape);
	glutDisplayFunc(Render);
	glutSpecialFunc(OnKeyboard);
	//

	GLenum err = glewInit();
	if(GLEW_OK != err)
	{
		fprintf(stderr, "Glew error: %s\n", glewGetErrorString(err));
		return 1;
	}

	//Init
	Init();

	//StartLoop
	glutMainLoop();

	return 0;
}