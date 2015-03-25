prog: main.o capacitor.o triangleMesh.o
	g++ -std=c++11 -o CreateVolumeData main.o capacitor.o triangleMesh.o 
capacitor.o: src/capacitor.cpp
	gcc -std=c++11 -c src/capacitor.cpp -I./include
				
triangleMesh.o: src/triangleMesh.cpp
	gcc -std=c++11 -c src/triangleMesh.cpp -I./include

main.o: main.cpp
	gcc -std=c++11 -stdlib=libc++ -c main.cpp -I./include

