prog: main.o capacitor.o triangleMesh.o
	g++ -std=c++0x -o CreateVolumeData main.o capacitor.o triangleMesh.o 
main.o: main.cpp
	gcc -std=c++0x -c main.cpp -I./include
capacitor.o: src/capacitor.cpp
	gcc -std=c++0x -c src/capacitor.cpp -I./include
triangleMesh.o: src/triangleMesh.cpp
	gcc -std=c++0x -c src/triangleMesh.cpp -I./include


