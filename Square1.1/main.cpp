#include <GLTools.h>
#include <iostream>
#include <conio.h>
#include <time.h>

#ifdef __APPLE__
#include <glut/glut.h>
#else
#define FREEGLUT_STATIC
#include <GL\glut.h>
#endif

#include "Agent.h"
#include "Vector3D.h"

#define QUADS_LENTH 12
//Mudar a quantidade de agentes na tela
#define QTDE_AGENT 500

Agent agents[QTDE_AGENT];
Agent agent(Vector3D(0.9, 0.9, 0.0), Vector3D(0.0, 0.0, 0.0));
Agent target(Vector3D(0.05, 0.05, 0.0), Vector3D(0.0, 0.0, 0.0));
Agent steering;

float verticeLenth = 0.05;

float vVertsTarget[QUADS_LENTH]; 
float vVertsAgent[QUADS_LENTH*QTDE_AGENT];

float xstep = 0.02;
float ystep = 0.02;
GLfloat stepSize = 0.025f;

float wh = 1, ww = 1;

UINT idVBO[QTDE_AGENT];

GLint first[QTDE_AGENT];
GLint count[QTDE_AGENT];

void OnReshape(int w, int h)
{
	glViewport(0,0,w,h);
}

void Init()
{
	glClearColor(0.0f, 0.5f, 1.0f, 1.0f);


	agent.AgentMovement(vVertsTarget, target.position, verticeLenth, 0);

	glGenBuffers(QTDE_AGENT, idVBO);

	glBindBuffer(GL_ARRAY_BUFFER, idVBO[0]);
	glBufferData(GL_ARRAY_BUFFER, QUADS_LENTH*sizeof(float), vVertsTarget, GL_DYNAMIC_DRAW);


	float r1, r2;
	int r;
	Vector3D vector[QTDE_AGENT];

	for(int j = 1; j < QTDE_AGENT; j++)
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
		agents[j] = Agent(Agent(Vector3D(r1,r2,0.0), Vector3D(0.0,0.0,0.0)));

		agent.AgentMovement(vVertsAgent, agents[j].position, verticeLenth, j*12);
		
	}

		glBindBuffer(GL_ARRAY_BUFFER, idVBO[1]);
		glBufferData(GL_ARRAY_BUFFER, (QUADS_LENTH*QTDE_AGENT)*sizeof(float), vVertsAgent, GL_DYNAMIC_DRAW);


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

	glBindBuffer(GL_ARRAY_BUFFER, idVBO[0]);
	glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, 0);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

	glBindBuffer(GL_ARRAY_BUFFER, idVBO[1]);
	glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, 0);
	glMultiDrawArrays(GL_QUAD_STRIP, first, count, QTDE_AGENT);

	for(int i = 1; i < QTDE_AGENT; i++)
	{

		agents[i].force = agents[i].calculate_steering(target.position);

		agents[i].velocity = agents[i].force.truncVector(agents[i].force, MAX_FORCE);

		agents[i].position.x += agents[i].velocity.x * stepSize;
		agents[i].position.y += agents[i].velocity.y * stepSize;
		agents[i].position.z += agents[i].velocity.z * stepSize;

		agent.AgentMovement(vVertsAgent, agents[i].position, verticeLenth, i*12);

		//printf("%f\n", agent.position.x);

	}

	glBindBuffer(GL_ARRAY_BUFFER, idVBO[1]);
	glBufferData(GL_ARRAY_BUFFER, (QUADS_LENTH*QTDE_AGENT)*sizeof(float), vVertsAgent, GL_DYNAMIC_DRAW);


	glutSwapBuffers();

	glutPostRedisplay();
}

void OnKeyboard(int key, int x, int y)
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

	agent.AgentMovement(vVertsTarget, target.position, verticeLenth,0);

	glBindBuffer(GL_ARRAY_BUFFER, idVBO[0]);
	glBufferData(GL_ARRAY_BUFFER, QUADS_LENTH*sizeof(float), vVertsTarget, GL_DYNAMIC_DRAW);

	glutPostRedisplay(); 
}

int main(int argc, char *argv[])
{

	srand ( time(NULL) );

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