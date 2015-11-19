<cfscript>
    //Working directory
    directory = "#getDirectoryFromPath( getTemplatePath() )#images/";

    //Get an instance of the sample image that will be resized
    sampleImg = new cf_imagen( directory,
                               '_sample.jpg',
                               true );

    //If form submited
    if( isDefined( 'form.submit' ) ){
        //Changes width preserving proportions
        sampleImg.resize( form.width );

        if( isDefined( 'form.directory' ) and form.directory neq '' ){
        	destination = '#getDirectoryFromPath( getCurrentTemplatePath() )##form.directory#/';
        	dir = form.directory;
        }else{
        	destination = directory;
        	dir = 'images';
        }

	    //Save to disk with the new name if form.name is not specified the sample image will be overwritten
        sampleImg.save( form.name, destination );

        //Create an instance of the saved image
        imgObj = new cf_imagen( destination,
                                sampleImg.getName(),
                                true );

        //Crate thumbnail if needed
        if( isDefined( 'form.thumbnail' ) and form.thumbnail ){
            if( isDefined( 'form.thumbnailName' ) and form.thumbnailName neq '' ){
            	//Set custom name of the thumbnail
            	imgObj.setThumbName( form.thumbnailName );
            }
            imgObj.createThumbnail();
        }

	    //Success message
        message.body = 'Image saved as #sampleImg.getName()#';
        //Bootstrap class
        message.type = 'success';

    }
    //If deleting
    if( isDefined( 'delete' ) and delete neq '' ){
    	directory = "#getDirectoryFromPath( getTemplatePath() )##dir#/";
    	//Delete image
    	imgObj = new cf_imagen( directory,
    	                        delete );
    	imgObj.delete();

    	//Delete thumbnail
    	if( isDefined( 'thumb' ) and thumb neq '' ){
    		imgObj = new cf_imagen( directory,
                                    thumb );
            imgObj.delete();
    	}

    	message.body = 'Image deleted';
    	message.type = 'danger';
    }
</cfscript>

<cfoutput>
<html>
	<head>
	    <title>Resize and rename existing image</title>
	    <link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css" rel="stylesheet" integrity="sha256-MfvZlkHCEqatNoGiOXveE8FIwMzZg4W85qfrfIFBfYc= sha512-dTfge/zgoMYpP7QbHy4gWMEGsbsdZeCXz7irItjcC3sPUFtf0kuFbDz/ixG7ArTxmDjLXDmezHubeNikyKGVyQ==" crossorigin="anonymous">
	    <script src="https://code.jquery.com/jquery-2.1.4.min.js"></script>
	    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js" integrity="sha256-Sk3nkD6mLTMOF0EOpNtsIry+s1CsaqQC1rVLTAy+0yc= sha512-K1qjQ+NcF2TYO/eI3M6v8EiNYZfA95pQumfvcVrTHtwQVDG+aHRqLi/ETn2uB+1JqwYqVG3LIvdm9lj6imS/pQ==" crossorigin="anonymous"></script>
	</head>
	<body>
        <div class="container">
			<h2>Resize and rename an existing image</h2>
			<h4>Use case</h4>
            <p>John Doe needs to create a copy of an image already living in the server or change its size and replace it.
			   The copy of the image could be saved in a different directory than the original</p>
	        <p>This example takes an existing image on the server, renames it and resizes it according to the parameters specified in the form. <br />
	          The new image will be shown after process is finished.
	        </p>
	        <h4>Features shown</h4>
	        <div class="row">
		        <div class="col-md-9">
					<ul>
	                    <li>
	                        Resize image.<br />
<pre>
object = new cf_imagen( directory, imageName );
object.resize( 300 ); //Modify only width preserving proportions
object.save();
</pre>
	                    </li>
	                    <li>
		                    Rename image.<br />
<pre>
object = new cf_imagen( directory, imageName );
object.save( 'newName.jpg' );
</pre> or
<pre>
object = new cf_imagen( directory, imageName );
object.setName( 'newName.jpg' );
object.save();
</pre>
						</li>
	                    <li>
		                    Create thumbnail with custom file name.<br />
<pre>
object = new cf_imagen( directory, imageName );
object.setThumbName( 'myCustomThumbname.jpg' );
object.createThumbnail();
</pre>
						</li>
	                    <li>
		                    Delete image.<br />
<pre>
object = new cf_imagen( directory, imageName );
object.delete();
</pre>
						</li>
	                </ul>

	                <p>When calling the <code>object.save()</code> method, the image will be saved in the same directory, if you want to save it in
					   a different directory call the method with the directory argument <code>object.save( directory = myNewDirectory )</code>, if the directory
					   does not exist it will be created, the original image will be preserved.
					</p>
				</div>
			</div>
		</div>

	    <div class="container-fluid">
	       <h3>Sample image</h3>
	       <img src="images/_sample.jpg" />
	       <ul>
              <li>Name: #sampleImg.getInfo().name#</li>
              <li>Width: #sampleImg.getInfo().width# px</li>
              <li>Height: #sampleImg.getInfo().height# px</li>
              <li>Directory: #sampleImg.getInfo().directory#</li>
           </ul>

	       <cfif isDefined( 'message' )>

	           <p class="alert alert-#message.type#">#message.body#</p>

	           <cfif fileExists( '#imgObj.getDirectory()##imgObj.getName()#' )>
	                <cfif imgObj.hasThumb()>
					    <cfset thumbParam = '#imgObj.getThumbInfo().name#' />
					<cfelse>
					    <cfset thumbParam = '' />
					</cfif>
				    <h3>Saved image</h3>
				    <img src="#isDefined( 'form.directory' ) and form.directory neq '' ? form.directory : 'images'#/#imgObj.getName()#" />
				    <ul>
					   <li>Name: #imgObj.getInfo().name#</li>
					   <li>Width: #imgObj.getInfo().width# px</li>
					   <li>Height: #imgObj.getInfo().height# px</li>
					   <li>Directory: #imgObj.getInfo().directory#</li>
					   <li>
						   <a href="#CGI.SCRIPT_NAME#?delete=#imgObj.getName()#&dir=#dir#&thumb=#thumbParam#" class="btn btn-danger">
							   Delete image
						   </a>
					   </li>
					</ul>
				    <cfif imgObj.hasThumb()>
					   <h3>Thumbnail</h3>
					   <img src="#isDefined( 'form.directory' ) ? form.directory : images#/#imgObj.getThumbName()#" />
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
	                        <label for="name">Name</label>
	                        <input type="text" name="name" id="name" class="form-control" placeholder="Name of the image i.e myNewImage.jpg" />
	                    </div>
	                    <div class="form-group">
	                        <label for="width">Width</label>
	                        <input type="text" name="width" id="width" class="form-control" placeholder="Width of the uploaded image in pixels" />
	                    </div>
	                    <div class="form-group">
                            <label for="thumbnail">Create thumbnail
                                <input type="checkbox" name="thumbnail" id="thumbnail" value="true" />
							</label>
                        </div>
						<div class="form-group">
                            <label for="thumbnail">Thumbnail name</label>
                            <input type="text" name="thumbnailName" id="thumbnailName" class="form-control" value="" placeholder="Empty defaults to <name>_thumb.<extension>" />
                        </div>
						<div class="form-group">
                            <label for="name">Directory</label>
                            <input type="text" name="directory" id="directory" class="form-control" placeholder="Empty defaults to /images directory" />
                        </div>

	                    <button name="submit" class="btn btn-success">Resize</button>
	                </form>
	            </div>
	        </div>
		</div>

	</body>
</html>
</cfoutput>