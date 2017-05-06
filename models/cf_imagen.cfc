/**
 * Copyright (c) 2015 Angel Chrystian Torres
 * @author Angel Chrystian Torres
 * @date 10/11/15
 * @website elangelito.mx
 * @Description
 *  This component manipulates images, and performs uploads and deletes on server.
 *  createTextWatermark function fully works on ColdFusion Server, in Lucee and Railo the text watermark will only be inserted in the
 *  Left-Top corner due to imageDrawText function does not returns the height and with of the inserted text like ColdFusion making difficult
 *  to calculate the position to insert the text.
 *
 * How to use:
 * Refer to the examples
 *   http://elangelito.mx/cf_imagen/examples
 **/
component accessors=true {

	property name="directory"      default="";
	property name="name"           default="";
	property name="thumbName"      default="";
	property name="imageInstance";
	property name="thumbInstance";


/**@Displayname Init
 * Initialize name and directory for the image
 * @directory.hint      Physical path to the image file, if not exists the directory will be created.
 * @name.hint           The name of the file including extension
 * @instantiate.hint    If true and the image exists, an instance of a coldfusion image will be created.
 **/
	any function init( required string directory,
	                   required string name,
	                   boolean instantiate = false ){

		//Working direcory
		variables.directory = arguments.directory;
        if( !directoryExists( arguments.directory ) ){
            directoryCreate( arguments.directory );
        }

		//File extension
		var fileExtension = listLast( arguments.name, '.' );
		//Name without extension
		var nameNoExtension = listFirst( arguments.name, '.' );

		//Put the name in the private scope
		variables.name = arguments.name;
		//Create the name of the thumb
		variables.thumbName = '#nameNoExtension#_thumb.#fileExtension#';

		//Create a cf image if the file exists
		if( arguments.instantiate and fileExists( '#directory##name#' ) ){
            variables.imageInstance = imageNew( '#directory##name#' );
		}

		return this;
	}

/**@Displayname setInstance
 * Sets the instance image, if a coldfusion image is created outside and needs to be modified with this
 * component methods, set it here.
 * @Image.hint CF Image instance
 **/
    public any function setInstance( required any Image ){
    	variables.imageInstance = arguments.Image;
    }


/**@Displayname Resize
 * Resize an image
 * @width.hint      The width of the image that will be saved.
 * @height.hint     The new height of the instantiated image
 * @quality.hint    The quality of the resulting image according to the parameters of the cf function "imageScaleToFit" defaults to highestQuality
 **/
    public any function resize( width = '',
                                height = '',
                                quality = 'highestQuality' ){

    	ImageScaleToFit( imageInstance,
    	                 arguments.width,
    	                 arguments.height,
    	                 arguments.quality );

    }


/**@Displayname Save
 * Saves the instantiated image to disk
 * @name.hint       The name of the image if omitted the name especified in the init function will be used.
 * @directory.hint  The directory where the image will be saved, if omitted the directory specified in the init function will be used.
 * @quality.hint    The quality of the saved image valid only for jpg values from 0..1, 0 lowest quality and 1 the max quality.
 * @overwrite.hint  If true the image will be overwritten if an image with the same name already exists in disc.
 **/
   public any function save( string name = '',
                             string directory = '',
                             numeric quality = 1,
                             boolean overwrite = true ){

        //Overwrite the directory if passed as argument
        var path = arguments.directory neq '' ? arguments.directory : variables.directory;
        //Overwrite the name of the image if passes as argument
        variables.name = arguments.name neq '' ? arguments.name : variables.name;

        //File extension
        var fileExtension = listLast( variables.name, '.' );
        var nameNoExtension = listFirst( variables.name, '.' );

        //Create the name of the thumb
        variables.thumbName = '#nameNoExtension#_thumb.#fileExtension#';

        //Create directory if not exists
        if( not directoryExists( path ) ){
        	directoryCreate( path );
        }

        //Write image to disk
        imageWrite( imageInstance,
                    '#path##variables.name#',
                    arguments.quality,
                    arguments.overwrite );

    }


/**@Displayname Upload
 * Upload a file to the server
 * @destination.hint     Full path where the file will be uploaded
 * @fileField.hint       Name of the variable that contains the image file to be uploaded i.e. "FORM.image"
 * @nameConflict.hint    error,skip,overwrite,makeUnique. Defaults to overwrite
 * @accept.hint          Type of image accepted
 * @thumbnail.hint       If true a thumbnail of the image will be created along with the uploaded image <name>_thumb.<extension>
 **/
    public any function upload( required string fileField,
                                string destination,
                                string nameConflict = 'overwrite',
                                string accept="image/jpg,image/jpeg,image/gif,image/png,application/pdf",
                                boolean thumbnail = false ){

    	//Sets the destination to the values specified in the init function if not passed as argument
    	var destino = isDefined('arguments.destination') ? arguments.destination : '#variables.directory##variables.name#';

    	//Upload the image
    	fileUpload( destino,
    	            arguments.fileField,
    	            arguments.accept,
    	            arguments.nameConflict );

    	//Instantiate the image file
    	variables.imageInstance = imageNew( destino );

    	//Create a thumbanail if required
    	if( arguments.thumbnail ){
    	   createThumbnail();
    	}

    	return;
    }


/**@Displayname delete
 * Delete the instantiated image and its thumbnail if exists
 **/
    public any function delete(){
       //Check if image exists
        if( fileExists( '#variables.directory##variables.name#' ) ){
        	//Delete the thumbnail
        	if( fileExists( '#variables.directory##variables.thumbName#' ) ){
        		fileDelete( '#variables.directory##variables.thumbName#' );
        	}

        	//Delete the image
        	fileDelete( '#variables.directory##variables.name#' );
        }

    	return;
    }


/**@Displayname createThumbnail
 * Create a thumbnail from an instantiated image
 * @width.hint  Width of the thumbnail
 * @height.hint Height of the thumbnail
 **/
    public any function createThumbnail( numeric width,
                                         numeric height,
                                         numeric ratio = 1.618 ){
    	var thumbWidth = '';
        var thumbHeight = '';

    	//Create a copy of the instanced image
    	var thumb = ImageNew( variables.imageInstance );

    	//By default the width is calculated by dividing by phi number (golden ratio) thats how nature would c.
    	//No special reason, you can change the ratio for whatever value you want
    	if( not isDefined( 'arguments.width' ) ){
            thumbWidth = ImageGetWidth( variables.imageInstance ) / RATIO / RATIO;
    	}else{
    		thumbWidth = arguments.width;
    	}

    	//By default the height is calculated by dividing by phi number.
        //No special reason, you can change the ration for whatever value you want to maintain proportion
        //it must be the same ratio that width
    	if( not isDefined( 'arguments.height' ) ){
    		thumbHeight = ImageGetHeight( imageInstance ) / RATIO / RATIO;
    	}else{
    		thumbHeight = arguments.height;
    	}

        //Resize the image copy
    	ImageScaleToFit( thumb,
    	                 thumbWidth,
    	                 thumbHeight,
    	                 'highestQuality' );

    	//In case the directory of thumbs changed created if not exists
        if( not directoryExists( variables.directory ) ){
            directoryCreate( variables.directory );
        }

    	//Write to disk
    	imageWrite( thumb, '#variables.directory##thumbName#', 1, true );

    	//Set the thumbnail instance as a property of the object
    	variables.thumbInstance = thumb;

    }


/**@Displayname hasThumb
 * Return true if the instantiated image has a thumbnail, searches in the same directory for an image named <name>_thumb.<extension>
 **/
    public boolean function hasThumb(){

    	return fileExists('#variables.directory##variables.thumbName#');

    }


/**@Displayname getInfo
 * Return a struct with the image information plus the path and name
 **/
    public struct function getInfo(){
    	//Get the image information
    	var info = ImageInfo( imageInstance );
    	var fileInfo = {
	    		directory = variables.directory,
	    		name = variables.name
	    	};
	    //Add path information to the info
    	structAppend( info, fileInfo );

    	return info;
    }


/**@Displayname getThumbInfo
 * Returns a struct with the thumbnail information plus the path and name
 **/
    public struct function getThumbInfo(){
        //Get the image information
        var info = ImageInfo( thumbInstance );
        var fileInfo = {
                directory = variables.directory,
                name = variables.thumbName
            };
        //Add path information to the info
        structAppend( info, fileInfo );

        return info;
    }


/**@Displayname isLandscape
 * Returns true if width is larger than height
 **/
    public any function isLandscape(){
        if( not isNull( variables.imageInstance ) ){
        	var width = ImageGetWidth( variables.imageInstance );
        	var height = ImageGetHeight( variables.imageInstance );
        	return width gt height;
        }
    	return;
    }


/**@Displayname isPortrait
 * Returns true if height is larger than width
 **/
    public any function isPortrait(){
        if( not isNull( variables.imageInstance ) ){
            var width = ImageGetWidth( variables.imageInstance );
            var height = ImageGetHeight( variables.imageInstance );
            return height gt width;
        }
        return;
    }


/**@Displayname createImageWatermark
 * I add an image watermark to the instanced image
 * @watermark.hint           Full path to the watermark image
 * @horizontalPosition.hint  Horizontal position for the watermark left|center|right
 * @verticalPosition.hint    Vertical position for the watermark top|middle|bottom
 * @destination.hint         Full path where the image will be saved if omitted the working directory will be used
 * @width.hint               Width of the watermark
 * @height.hint              Height of the watermark
 * @name.hint                Name of the resulting image optional, default original name
 **/
    public any function createImageWatermark( required string watermark,
                                              string horizontalPosition = 'right',
                                              string verticalPosition = 'bottom',
                                              string width = '',
                                              string height = '',
                                              boolean transparency = false,
                                              string colorTransparency = 'white',
                                              string destination = '',
                                              string name = '' ){

        //Coordinates for top-left by default
        var coordinates = { x = 0, y = 0 };

        //Create a CF image from original
        var originalImage = variables.imageInstance;
        //Create a CF image from watermark
        var watermarkImage = imageNew( arguments.watermark );

        //Resize if needed
        if( arguments.width neq '' or arguments.height neq '' ){
        	imageScaleToFit( watermarkImage, arguments.width, arguments.height, 'highestQuality' );

        }

        //Variables to calculate position of watermark
        originalHeight = imageGetHeight( originalImage ); //Height of the original image
        originalWidth = imageGetWidth( originalImage ); //Width of the original image
        watermarkHeight = imageGetHeight( watermarkImage ); //Height of the watermark image
        watermarkWidth = imageGetWidth( watermarkImage ); //Width of the watermark image

        //For Position watermark on the top left
        if( arguments.horizontalPosition eq 'center' and arguments.verticalPosition eq 'top' ){
            coordinates = { x = ( originalWidth - watermarkWidth ) / 2,
                            y = 0 };
        }else if( arguments.horizontalPosition eq 'right' and arguments.verticalPosition eq 'top' ){
            //For top-right position
            coordinates = { x = ( originalWidth - watermarkWidth ),
                            y = 0};
        }else if( arguments.horizontalPosition eq 'left' and arguments.verticalPosition eq 'middle' ){
            //For middle-left position
            coordinates = { x = 0,
                            y = ( originalHeight - watermarkHeight ) / 2 };
        }else if( arguments.horizontalPosition eq 'center' and arguments.verticalPosition eq 'middle' ){
            //For middle-center position
            coordinates = { x = ( originalWidth - watermarkWidth ) / 2,
                            y = ( originalHeight - watermarkHeight ) / 2 };
        }else if( arguments.horizontalPosition eq 'right' and arguments.verticalPosition eq 'middle' ){
            //For middle-right position
            coordinates = { x = ( originalWidth - watermarkWidth ),
                            y = ( originalHeight - watermarkHeight ) / 2 };
        }else if( arguments.horizontalPosition eq 'left' and arguments.verticalPosition eq 'bottom' ){
            //For bottom-left position
            coordinates = { x = 0,
                            y = ( originalHeight - watermarkHeight ) };
        }else if( arguments.horizontalPosition eq 'center' and arguments.verticalPosition eq 'bottom' ){
            //For bottom-center position
            coordinates = { x = ( originalWidth - watermarkWidth ) / 2,
                            y = ( originalHeight - watermarkHeight ) };
        }else if( arguments.horizontalPosition eq 'right' and arguments.verticalPosition eq 'bottom' ){
            //For bottom-right position
            coordinates = { x = ( originalWidth - watermarkWidth ),
                            y = ( originalHeight - watermarkHeight ) };
        }

        //If transparency apply to watermark only coldFusion not supported in railo, lucee
        try{
            if( arguments.transparency ){
	            imageMakeColorTransparent( watermarkImage, arguments.colorTransparency );
	        }
        }catch( any e ){}


        //Set transparency
        imageSetDrawingTransparency( originalImage, 20 );

        //Paste the watermark image on the original at the designated coordinates
        imagePaste( originalImage,
                    watermarkImage,
                    coordinates.x,
                    coordinates.y );

        //Set the destination directory
        if( arguments.destination eq '' ){
        	arguments.destination = variables.directory;
            //If name of file in arguments, add id to the destination
            if( arguments.name eq '' ){
                arguments.name = variables.name;
            }
        }

        //Save image to disk
        imageWrite( originalImage, '#arguments.destination##arguments.name#' );

    }


/**@Displayname createTextWatermark
 * Inserts a string text as watermark in the image, position only works for coldfusion as lucee does not return the size of the text from
 * the imageDrawText function.
 * @text.hint               Text to insert as watermark
 * @horizontalPosition.hint Horizontal position of the text left|center|right
 * @verticalPosition.hint   Vertical position of the text top|middle|bottom
 * @textOptions.hit         Struct with the font options like size|font|style|underline
 * @color.hint              Color of the text watermark
 * @destination.hint        Directory where the image will be saved, if omitted working directory will be used
 * @name.hint               Name of the image that will be saved to disk.
 *
 **/
    public any function createTextWatermark( required string text,
                                             string horizontalPosition = 'right',
                                             string verticalPosition = 'bottom',
                                             struct textOptions = {},
                                             string color = 'white',
                                             string destination = '',
                                             string name= '' ){


        //Create the font options from arguments and default
        structAppend( arguments.textOptions,
                      { size = 10,
                        font = 'monospaced',
                        style= 'bold' },
                      false );

        //Coordinates for top-left by default
        var coordinates = { x = 0, y = 0 };

        //Variables to calculate position of watermark
        originalHeight = getInfo().height; //Height of the original image
        originalWidth = getInfo().width; //Width of the original image

        //Create a CF image from original
        var originalImage = imageCopy( variables.imageInstance, 0, 0, originalWidth, originalHeight );

        //Set the destination directory
        if( arguments.destination eq '' ){
            arguments.destination = variables.directory;
            //If name of file in arguments, add id to the destination
            if( arguments.name eq '' ){
                arguments.name = variables.name;
            }
        }

        //For Luce/Railo insert in the top left
        if( SERVER.COLDFUSION.productName neq 'ColdFusion Server' ){
            //Set color
            imageSetDrawingColor( variables.imageInstance, arguments.color );
            //Insert text
            imageDrawText( variables.imageInstance, arguments.text, 20, 20, arguments.textOptions );
            //Save image to disk
            imageWrite( variables.imageInstance, '#arguments.destination##arguments.name#' );
            return;
        }


        var temp = imageDrawText( originalImage, arguments.text, 0, 0, arguments.textOptions );

        //If text fits in the image
        if( temp.textWidth lt originalWidth ){
        	watermarkHeight = temp.textHeight;
        	watermarkWidth = temp.textWidth;
        }else{
        	while( temp.textWidth gt originalWidth ){
        		textOptions.size = decrementValue( textOptions.size );
        		temp = imageDrawText( originalImage, arguments.text, 0, 0, arguments.textOptions );
        	}
        	watermarkHeight = temp.textHeight;
            watermarkWidth = temp.textWidth;

        }

                //For Position watermark on the top left
        if( arguments.horizontalPosition eq 'center' and arguments.verticalPosition eq 'top' ){
            coordinates = { x = ( originalWidth - watermarkWidth ) / 2,
                            y = 0 + watermarkHeight };
        }else if( arguments.horizontalPosition eq 'right' and arguments.verticalPosition eq 'top' ){
            //For top-centert position
            coordinates = { x = ( originalWidth - watermarkWidth ) / 2,
                            y = 0 + watermarkHeight };
        }else if( arguments.horizontalPosition eq 'right' and arguments.verticalPosition eq 'top' ){
            //For top-right position
            coordinates = { x = ( originalWidth - watermarkWidth ),
                            y = 0 + watermarkHeight };
        }else if( arguments.horizontalPosition eq 'left' and arguments.verticalPosition eq 'middle' ){
            //For middle-left position
            coordinates = { x = 0,
                            y = ( originalHeight - watermarkHeight ) / 2 };
        }else if( arguments.horizontalPosition eq 'center' and arguments.verticalPosition eq 'middle' ){
            //For middle-center position
            coordinates = { x = ( originalWidth - watermarkWidth ) / 2,
                            y = ( originalHeight - watermarkHeight ) / 2 };
        }else if( arguments.horizontalPosition eq 'right' and arguments.verticalPosition eq 'middle' ){
            //For middle-right position
            coordinates = { x = ( originalWidth - watermarkWidth ),
                            y = ( originalHeight - watermarkHeight ) / 2 };
        }else if( arguments.horizontalPosition eq 'left' and arguments.verticalPosition eq 'bottom' ){
            //For bottom-left position
            coordinates = { x = 0,
                            y = ( originalHeight - watermarkHeight ) };
        }else if( arguments.horizontalPosition eq 'center' and arguments.verticalPosition eq 'bottom' ){
            //For bottom-center position
            coordinates = { x = ( originalWidth - watermarkWidth ) / 2,
                            y = ( originalHeight - watermarkHeight ) };
        }else if( arguments.horizontalPosition eq 'right' and arguments.verticalPosition eq 'bottom' ){
            //For bottom-right position
            coordinates = { x = ( originalWidth - watermarkWidth ),
                            y = ( originalHeight - watermarkHeight ) };
        }

        //Paste the watermark image on the original at the designated coordinates
        originalImage = imageCopy( variables.imageInstance, 0, 0, originalWidth, originalHeight );
        imageSetDrawingColor( originalImage, arguments.color );
        temp = imageDrawText( originalImage, arguments.text, coordinates.x, coordinates.y, textOptions );

        //Save image to disk
        imageWrite( originalImage, '#arguments.destination##arguments.name#' );


    	return;
    }

}