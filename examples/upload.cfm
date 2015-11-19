<cfscript>
    //If form submited
    if( isDefined( 'form.submit' ) ){

	    //Check if the image form field exists
	    if( !isDefined( 'form.image' ) ){
	        message.body = 'The image field does not exist';
	        //Bootstrap class
	        message.type = 'bg-danger';
	    }else{
	        //The image will be uploaded to a directory named "images" in the same path of upload.cfm
	        directory = "#getDirectoryFromPath( getTemplatePath() )#images/";
	        //Create an instance of the object
	        imgObj = new cf_imagen( directory,
	                                form.name );
	        //Upload the image
	        imgObj.upload( "form.image" );
	        //Resize the image
	        imgObj.resize( form.width );
	        //Create thumbnail from the new size
	        imgObj.createThumbnail();
	        //Save to disk
	        imgObj.save();

	        //Success message
	        message.body = 'Image uploaded';
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
	    <title>Image Upload and resize</title>
	    <link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css" rel="stylesheet" integrity="sha256-MfvZlkHCEqatNoGiOXveE8FIwMzZg4W85qfrfIFBfYc= sha512-dTfge/zgoMYpP7QbHy4gWMEGsbsdZeCXz7irItjcC3sPUFtf0kuFbDz/ixG7ArTxmDjLXDmezHubeNikyKGVyQ==" crossorigin="anonymous">
	    <script src="https://code.jquery.com/jquery-2.1.4.min.js"></script>
	    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js" integrity="sha256-Sk3nkD6mLTMOF0EOpNtsIry+s1CsaqQC1rVLTAy+0yc= sha512-K1qjQ+NcF2TYO/eI3M6v8EiNYZfA95pQumfvcVrTHtwQVDG+aHRqLi/ETn2uB+1JqwYqVG3LIvdm9lj6imS/pQ==" crossorigin="anonymous"></script>
	</head>
	<body>

        <div class="container">
			<h2>Image upload, resize and delete</h2>
			<h4>Use case</h4>
			<p>John Doe has an image and needs to upload it with a specific size in a specific directory, and create a thumbnail (small version)  of the uploaded image</p>
	        <p>This example uploads an image in a directory called "images/" at the same level of this executing script <br />
	          The file will be renamed according to <em>name field</em>, the extension must be specified i.e. myUploadedImage.jpg <br />
	          The image will be resized to <em>width field</em> and a thumbnail will be created.<br />
	          After upload, the uploaded image and thumbnail will be shown and a list of properties, then you can delete it.
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
                            Delete.<br />
<pre>
object = new cf_imagen( directory, imageName );
object.delete();
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
				    <h3>Uploaded image</h3>
				    <img src="images/#imgObj.getName()#" />
				    <ul>
					   <li>Name: #imgObj.getInfo().name#</li>
					   <li>Width: #imgObj.getInfo().width# px</li>
					   <li>Height: #imgObj.getInfo().height# px</li>
					   <li>Directory: #imgObj.getInfo().directory#</li>
					   <li><a href="#CGI.SCRIPT_NAME#?delete=#imgObj.getName()#" class="btn btn-danger">Delete image</a></li>
					</ul>
				    <cfif imgObj.hasThumb()>
					   <h3>Thumbnail</h3>
					   <img src="images/#imgObj.getThumbName()#" />
					   <ul>
                       <li>Name: #imgObj.getThumbInfo().name#</li>
                       <li>Width: #imgObj.getThumbInfo().width# px</li>
                       <li>Height: #imgObj.getThumbInfo().height# px</li>
                       <li>Directory: #imgObj.getThumbInfo().directory#</li>
                    </ul>
					</cfif>
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
	                        <label for="name">Name</label>
	                        <input type="text" name="name" id="name" class="form-control" placeholder="Name of the image i.e myNewImage.jpg" />
	                    </div>
	                    <div class="form-group">
	                        <label for="width">Width</label>
	                        <input type="text" name="width" id="width" class="form-control" placeholder="Width of the uploaded image in pixels" />
	                    </div>

	                    <button name="submit" class="btn btn-success">Upload</button>
	                </form>
	            </div>
	        </div>
		</div>

	</body>
</html>
</cfoutput>