prog: main.o capacitor.o triangleMesh.o
	g++ -o CreateVolumeData main.o capacitor.o triangleMesh.o 
main.o: main.cpp
	gcc -c main.cpp -I./include


capacitor.o: src/capacitor.cpp
	gcc -c src/capacitor.cpp -I./include

				
triangleMesh.o: src/triangleMesh.cpp
	gcc -c src/triangleMesh.cpp -I./include

