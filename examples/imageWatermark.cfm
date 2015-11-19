<!---
 * Copyright (c) 2015 Angel Chrystian Torres
 * @author Angel Chrystian Torres
 * @date 10/11/15
 * @website elangelito.mx
 * @Description
 *  This is an example of cf_imagen component to add an watermark to an image
 *
 * --->

<cfscript>
    //If form submited
    if( isDefined( 'form.submit' ) ){

	    //Check if the image form field exists
	    if( !isDefined( 'form.image' ) ){
	        message.body = 'The image field does not exist';
	        //Bootstrap class
	        message.type = 'bg-danger';
	    }else if( !isDefined( 'form.watermark' ) ){
	    	message.body = 'The watermark image field does not exist';
            //Bootstrap class
            message.type = 'bg-danger';
	    }else{
	        //The image will be uploaded to a directory named "images" in the same path of upload.cfm
	        directory = "#getDirectoryFromPath( getTemplatePath() )#watermarks/";
	        //Create an instance of the object for image
	        imgObj = new cf_imagen( directory,
	                                form.name );
	        //Upload the image
	        imgObj.upload( "form.image" );

	        //Create an instance of the object for watermark image
            img2Obj = new cf_imagen( directory,
                                     'watermark.png' );
            //Upload the image
            img2Obj.upload( "form.watermark" );

	        //Save image to disk
	        imgObj.save();
	        //Save watermark image to disk
            img2Obj.save();

            //Create the watermark
            imgObj.createImageWatermark( '#imgObj.getDirectory()#watermark.png',
                                         form.horizontalPosition,
                                         form.verticalPosition,
                                         form.width,
                                         '',
                                         true );

	        //Success message
	        message.body = 'Watermark created';
	        //Bootstrap class
	        message.type = 'success';
	    }

    }
    //If deleting
    if( isDefined( 'delete' ) and delete neq '' ){
    	directory = "#getDirectoryFromPath( getTemplatePath() )#watermarks/";
    	imgObj = new cf_imagen( directory,
    	                        delete );
    	imgObj.delete();

    	imgObj = new cf_imagen( directory,
                                'watermark.png' );
        imgObj.delete();

    	message.body = 'Image deleted';
    	message.type = 'danger';
    }
</cfscript>

<cfoutput>
<html>
	<head>
	    <title>Create image watermark</title>
	    <link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css" rel="stylesheet" integrity="sha256-MfvZlkHCEqatNoGiOXveE8FIwMzZg4W85qfrfIFBfYc= sha512-dTfge/zgoMYpP7QbHy4gWMEGsbsdZeCXz7irItjcC3sPUFtf0kuFbDz/ixG7ArTxmDjLXDmezHubeNikyKGVyQ==" crossorigin="anonymous">
	    <script src="https://code.jquery.com/jquery-2.1.4.min.js"></script>
	    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js" integrity="sha256-Sk3nkD6mLTMOF0EOpNtsIry+s1CsaqQC1rVLTAy+0yc= sha512-K1qjQ+NcF2TYO/eI3M6v8EiNYZfA95pQumfvcVrTHtwQVDG+aHRqLi/ETn2uB+1JqwYqVG3LIvdm9lj6imS/pQ==" crossorigin="anonymous"></script>
	</head>
	<body>

        <div class="container">
			<h2>Create image watermark</h2>
			<h4>Use case</h4>
			<p>John Doe needs to add the logo of the client when it uploads an image to the gallery of his site.
			</p>
	        <p>This example uploads an image in a directory called "watermarks/" at the same level of this executing script, the watermark image is renamed
		        to watermark.png and inserted at the position selected in the form.
	          The file will be renamed according to <em>name field</em>, the extension must be specified i.e. myUploadedImage.jpg <br />
	          After upload, the uploaded image with watermark will be shown and a list of properties, then you can delete it.
	        </p>

	        <div class="row">
			    <div class="col-md-7">
				    <h4>Features shown</h4>
				    <ul>
					    <li>
					        Upload.<br />
<pre>
object = new cf_imagen( directory, imageName );
object.upload();
</pre>
						</li>
						<li>
                            Create Image Watermark.<br />
<pre>
object.createImageWatermark();
</pre>
                        </li>
					</ul>
				</div>
			</div>
		</div>

	    <div class="container-fluid">
	       <cfif isDefined( 'message' )>

	           <p class="alert alert-#message.type#">#message.body#</p>

	           <cfif fileExists( '#imgObj.getDirectory()##imgObj.getName()#' )>
				    <h3>Saved image</h3>
				    <img src="watermarks/#imgObj.getName()#" />
				    <ul>
					   <li>Name: #imgObj.getInfo().name#</li>
					   <li>Width: #imgObj.getInfo().width# px</li>
					   <li>Height: #imgObj.getInfo().height# px</li>
					   <li>Directory: #imgObj.getInfo().directory#</li>
					   <li><a href="#CGI.SCRIPT_NAME#?delete=#imgObj.getName()#" class="btn btn-danger">Delete image</a></li>
					</ul>
			   </cfif>

	        </cfif>
			<div class="row">
	            <div class="col-md-4">
	                <form name="myForm" action="#CGI.SCRIPT_NAME#" method="post" enctype="multipart/form-data">
	                    <div class="form-group">
	                        <label for="image">Select an image</label>
	                        <input type="file" name="image" id="image" class="form-control" />
	                    </div>
	                    <div class="form-group">
                            <label for="image">Select watermark image</label>
                            <input type="file" name="watermark" id="watermark" class="form-control" />
                        </div>
	                    <div class="form-group">
	                        <label for="name">Name</label>
	                        <input type="text" name="name" id="name" class="form-control" placeholder="Name of the image i.e myNewImage.jpg" />
	                    </div>
	                    <div class="form-group">
	                        <label for="width">Watermark Width</label>
	                        <input type="text" name="width" id="width" class="form-control" placeholder="Width of the uploaded image in pixels" />
	                    </div>
	                    <div class="form-group">
						  <label for="horizontalPosition">Horizontal position</label>
						  <select name="horizontalPosition" id="horizontalPosition">
						      <option value="left">Left</option>
						      <option value="center">Center</option>
						      <option value="right">Right</option>
						  </select>
						</div>
						<div class="form-group">
                          <label for="horizontalPosition">Vertical position</label>
                          <select name="verticalPosition" id="verticalPosition">
                              <option value="top">Top</option>
                              <option value="middle">Middle</option>
                              <option value="bottom">Bottom</option>
                          </select>
                        </div>

	                    <button name="submit" class="btn btn-success">Upload</button>
	                </form>
	            </div>
	        </div>
		</div>

	</body>
</html>
</cfoutput>