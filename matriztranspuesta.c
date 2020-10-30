 /*Alejandro Hernandez Baca
 Transpuesta de una matriz*/

 int main()
 {
 int M[100][100];
  int T[100][100];
  unsigned int i,j,Filas,Columnas;

  printf("Programa que hace la transpuesta de una matriz que sea cuadrada\n\n");    /*No fui capaz de hacer que funcionase con todas las matrices, s�lo cuadradas :(*/
  printf("Numero de filas de la matriz:\n");
  scanf("%i",&Filas);
  printf("Numero de columnas de la matriz:\n");
  scanf("%i",&Columnas);

  /*Proceso para leer los valores de la matriz M*/

    for(i=0;i<Filas;i++)
      for(j=0;j<Columnas;j++)
	{
        printf("\n M1[%i][%i]= ",i,j);
        scanf("%i",&M[i][j]);
	}
  printf("\n");

/*Impresion de la Matriz M*/

  printf("\n Matriz M:");

   for(i=0;i<Filas;i++)
     {printf("\n");
        for(j=0;j<Columnas;j++)
          printf("\t%i",M[i][j]);
     }

/*Ciclo for para transponer la matriz*/

	for(i=0;i<Filas;i++)
     {printf("\n");
        for(j=0;j<Columnas;j++)
          T[j][i]=M[i][j];
	 }

	/*Impresion de la matriz transpuesta*/
	printf("\n Matriz Transpuesta:");
	for(i=0;i<Filas;i++)
     {printf("\n");
        for(j=0;j<Columnas;j++)
          printf("\t%i",T[i][j]);
     }
	printf("\n");
    return 0;
 }
