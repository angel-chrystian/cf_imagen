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

	        //Save image to disk
	        imgObj.save();

	        options = {};
	        if( form.size neq '' ){
	        	options.size = form.size;
	        }

	        args = { text = form.watermark,
	        	     horizontalPosition = form.horizontalPosition,
	        	     verticalPosition = form.verticalPosition,
	        	     textOptions = options };

	        if( form.color neq '' ){
	        	args.color = form.color;
	        }

            //Create the watermark
            imgObj.createTextWatermark( argumentCollection = args );

	        //Success message
	        message.body = 'Watermark created';
	        //Bootstrap class
	        message.type = 'success';
	    }

    }
    //If deleting
    if( isDefined( 'delete' ) and delete neq '' ){
    	directory = "#getDirectoryFromPath( getTemplatePath() )#images/";
    	imgObj = new cf_imagen( directory,
    	                        delete );
    	imgObj.delete();
    	message.body = 'Image deleted';
    	message.type = 'danger';
    }
</cfscript>

<cfoutput>
<html>
	<head>
	    <title>Create text watermark</title>
	    <script src="https://code.jquery.com/jquery-2.1.4.min.js"></script>
	    <link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css" rel="stylesheet" integrity="sha256-MfvZlkHCEqatNoGiOXveE8FIwMzZg4W85qfrfIFBfYc= sha512-dTfge/zgoMYpP7QbHy4gWMEGsbsdZeCXz7irItjcC3sPUFtf0kuFbDz/ixG7ArTxmDjLXDmezHubeNikyKGVyQ==" crossorigin="anonymous">
	    <script src="https://code.jquery.com/jquery-2.1.4.min.js"></script>
	    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js" integrity="sha256-Sk3nkD6mLTMOF0EOpNtsIry+s1CsaqQC1rVLTAy+0yc= sha512-K1qjQ+NcF2TYO/eI3M6v8EiNYZfA95pQumfvcVrTHtwQVDG+aHRqLi/ETn2uB+1JqwYqVG3LIvdm9lj6imS/pQ==" crossorigin="anonymous"></script>
	</head>
	<body>

        <div class="container">
			<h2>Create text watermark</h2>
			<h4>Use case</h4>
            <p>John Doe needs to add the URL of the client's web site when he uploads an image to the gallery of his site.
            </p>
	        <p>This example uploads an image in a directory called "watermarks/" at the same level of this executing script, the text will be added to the image
		        in the position, size and color selected in the form. <br />
		        Note*( In Lucee will only be placed at the top-left position regardless of the selection because
		        Lucee does not return the width and height of the inserted text with the function <code>imageDrawText()</code> making harder to calculate
		        the position)<br />
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
                            Create text Watermark.<br />
<pre>
object.createTextWatermark();
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
                            <label for="image">Type the watermark text</label>
                            <input type="text" name="watermark" id="watermark" class="form-control" />
                        </div>
	                    <div class="form-group">
	                        <label for="name">Name</label>
	                        <input type="text" name="name" id="name" class="form-control" placeholder="Name of the image i.e myNewImage.jpg" />
	                    </div>
	                    <div class="form-group">
	                        <label for="width">Text color</label>
	                        <input type="text" name="color" id="color" class="form-control" value="red" placeholder="Valid html/css color name" />
	                    </div>
	                    <div class="form-group">
                            <label for="width">Font size</label>
                            <input type="text" name="size" id="size" class="form-control" placeholder="Font size empty defaults to 10 points" />
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