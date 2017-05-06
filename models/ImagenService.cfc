component accessors="true"{
	property name="directorioFotos"    default="";
	property name="directorioThumbs"   default="";
	property name="directorioSmalls"   default="";
	property name="arrayThumbs"        setters="false";
	property name="arrayFotos"         setters="false";
	property name="arraySmalls"        setters="false";
	property name="options";
	property name="wirebox"    inject="wirebox";

/**
 * Constructor
 * ==========================================================================
 **/

	function init(){
        variables.arrayFotos = [];
        variables.arraySmalls = [];
        variables.arrayThumbs = [];
		return this;
	}


/**@Displayname configure
 * Configuro el directorio de trabajo
 * @ruta.hint Ruta completa del directorio de trabajo
 **/
    public any function configure( required string ruta,
                                   opts = {} ){

        variables.options = { bigWidth    = 1200,
		        	          bigHeight   = 900,
		        	          smallWidth  = 600,
		        	          smallHeight = 450,
		        	          thumbWidth  = 133,
		        	          thumbHeight = 133 };

        structAppend( variables.options, arguments.opts, true );

        variables.directorioFotos = '#arguments.ruta#big/';
        variables.directorioSmalls = '#arguments.ruta#small/';
        variables.directorioThumbs = '#arguments.ruta#thumb/';

        //Si no existen los directorios los creo
        if( not directoryExists( directorioFotos ) ){
            directoryCreate( variables.directorioFotos );
        }
        if( not directoryExists( directorioSmalls ) ){
            directoryCreate( variables.directorioSmalls );
        }
        if( not directoryExists( directorioThumbs ) ){
            directoryCreate( variables.directorioThumbs );
        }

        //El query de fotos representa el listado de nombres de los archivos
        updateArrayFotos();
    	return;
    }


 /**
  * @Displayname Actualizar Query
  * Actualizo el parametro del queryFotos a partir de las imágenes en el directorio
  *
  **/
  public any function updateArrayFotos(){
     arrayClear( arrayThumbs );
     arrayClear( arraySmalls );
     arrayClear( arrayFotos );

     variables.arrayFotos = directoryList( variables.directorioFotos, false, 'name', '*.jpg' );
     variables.arraySmalls = directoryList( variables.directorioSmalls, false, 'name', '*.jpg' );
     variables.arrayThumbs = directoryList( variables.directorioThumbs, false, 'name', '*.jpg' );

  }


 /**@Displayname agregarImagen
 * Agrego una imagen al producto
 * ======================================================================================================
 **/
    public any function upload( string nombre = '',
                                string fieldName = 'form.imagen' ){

    	//Si no se pasa el índice el  nombre de la imagen será el siguiente entero mayor al tamaño del query
        arguments.nombre = arguments.nombre eq '' ? generarNombre() : arguments.nombre;

	    //Subo la imagen Big
	    var imgObj = wirebox.getInstance( name = 'services.cf_imagen',
	                                      initArguments = { directory = variables.directorioFotos,
	                                                        name = arguments.nombre } );
	    imgObj.upload( arguments.fieldName );
	    imgObj.resize( options.bigWidth, options.bigHeight );
	    imgObj.save();

	    imgObj.resize( options.smallWidth, options.smallHeight );
	    imgObj.save( directory = variables.directorioSmalls );

	    imgObj.resize( options.thumbWidth, options.thumbHeight );
	    imgObj.save( directory = variables.directorioThumbs );

	    updateArrayFotos();

    }


/**@Displayname getImagenes
 * Devuelvo un arreglo con objetos de imagen
 * ======================================================================================================
 **/
    public struct function getImagenes(){
        var imagenes = {};
        imagenes.arrayFotos = [];
        imagenes.arraySmalls = [];
        imagenes.arrayThumbs = [];

        updateArrayFotos();

        var dirs = [ { dir = 'directorioFotos', a = 'arrayFotos' },
                     { dir = 'directorioSmalls', a = 'arraySmalls' },
                     { dir = 'directorioThumbs', a = 'arrayThumbs' } ];

        for( var actual in dirs ){
            imagenes[ actual.a ] = [];
	        for( var nombreImagen in variables[ actual.a ] ){

	            initArguments = { directory = variables[ actual.dir ],
	                              name = nombreImagen,
	                              instantiate = true };

	            arrayAppend( imagenes[ actual.a ], wirebox.getInstance( name = 'services.cf_imagen',
	                                                                    initArguments = initArguments ) );

	        }
        }
		
        return imagenes;
    }



/**@Displayname generarNombre
 * Genero un nombre a partir del tamaño del arreglo
 * ======================================================================================================
 **/
    public any function generarNombre(){
        var tope = arrayLen( arrayFotos ) + 1;
        var nombre = "#numberFormat( tope ,'000' )#.jpg";

        return nombre;

    }


/**@Displayname delete
 * Elimino una imagen
 * ======================================================================================================
 **/
    public any function delete( nombreImagen ){
    	var imgObj = wirebox.getInstance( name = 'services.cf_imagen',
    	                                  initArguments = { directory = directorioFotos,
                                                            name = nombreImagen } );

        imgObj.delete();
        imgObj.setDirectory( directorioSmalls );
        imgObj.delete();
        imgObj.setDirectory( directorioThumbs );
        imgObj.delete();
        reindexar();
    	return;
    }


/**@Displayname reindexar
 * Reindexo los nombres de las imágenes después de eliminar
 * ======================================================================================================
 **/
    public any function reindexar(){
        var cont = 1;
        var nombreNuevo = '';
        var imagenes = getImagenes();

        for( var arreglo in imagenes ){
        	cont = 1;
        	for( var Imagen in imagenes[ arreglo ] ){
        		nombreNuevo = '#numberFormat( cont ,'000')#.jpg';
        		fileMove( '#Imagen.getDirectory()##Imagen.getName()#',
        		          '#Imagen.getDirectory()##nombreNuevo#');

        		cont = incrementValue( cont );
        	}
        }

    }

}

