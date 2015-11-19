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
	        directory = "#getDirectoryFromPath( getTemplatePath() )#images_3/";
	        //Create an instance of the object
	        imgObj = new cf_imagen( directory,
	                                form.name );
	        //Upload the image
	        imgObj.upload( "form.image" );

	        //Resize the image
	        imgObj.resize( form.width1 );
	        //Save to disk the first image
	        imgObj.save();

	        //Get the name of the file without extension to add a suffix
	        nameNoExtension = listFirst( imgObj.getName(), '.' );
	        //Resize to the second width
	        imgObj.resize( form.width2 );

	        imgObj.save( '#nameNoExtension#_2.jpg' );
	        //Resize to the third width
	        imgObj.resize( form.width3 );
	        imgObj.save( '#nameNoExtension#_3.jpg' );

	        //Success message
	        message.body = 'Image uploaded';
	        //Bootstrap class
	        message.type = 'success';
	    }

    }
    //If deleting
    if( isDefined( 'delete' ) and delete neq '' ){
    	directory = "#getDirectoryFromPath( getTemplatePath() )#images_3/";
    	noExtension = listFirst( delete, '.' );
    	image1 = delete;
    	image2 = '#noExtension#_2.jpg';
    	image3 = '#noExtension#_3.jpg';

    	//Create instance
    	imgObj = new cf_imagen( directory,
    	                        image1 );

    	//Delete image 1
    	imgObj.delete();
    	//Set name to image2
    	imgObj.setName( image2 );
    	//Delete image 2
    	imgObj.delete();
    	//Set name to image3
    	imgObj.setName( image3 );
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
			<h2>Upload image and create 3 different versions</h2>
			<h4>Use case</h4>
            <p>The web designer delivered to John Doe a template of a blog that uses different sizes of the same image, one to show in the post, another smaller to
				show in the list of posts of certain category and another even smalle to show in a side bar with the latest posts; so when the user writes the post and uploads
			    the related image, the application needs to create all the 3 fixed size versions of the image</p>

	        <p>This example uploads an image and writes 3 versions with different sizes each one in a folder called "images_3/" at the same level of this executing script <br />
	          The first image will be renamed according to <em>name field</em>, the other two will be appended with a suffix "_2" and "_3" respectively the extension must be specified i.e. myUploadedImage.jpg <br />
	          Resulting in myUploadedImage.jpg, myUploadedImage_2.jpg, myUploadedImage_3.jpg; no thumbnail will be created.
	        </p>

	        <div class="row">
			    <div class="col-md-7">
				    <h4>Features shown</h4>
				    <ul>
					    <li>
					        Upload.<br />
<pre>
object = new cf_imagen( directory, imageName );
object.upload(); //Uploads an image
</pre>
						</li>
						<li>
                            Resize.<br />
<pre>
object.resize( 300 ); //Modify only width preserving proportions
</pre>
                        </li>
						<li>
                            Write to disk and/or rename.<br />
<pre>
object.save();//Writes an image to disk
</pre>
                        </li>
						<li>
                            Get Info.<br />
<pre>
object.getInfo(); //Gets metadata of an image
</pre>
                        </li>
					</ul>
				</div>
			</div>
		</div>

	    <div class="container-fluid">
	       <cfif isDefined( 'message' ) and not isDefined( 'delete' )>
	           <cfscript>
			       //Name without extension
			       name = listFirst( imgObj.getName(), '.' );
			       //Names of images
			       names = { name1 = FORM.name,
			                 name2 = '#nameNoExtension#_2.jpg',
			                 name3 = '#nameNoExtension#_3.jpg' };
			       objects = {};
			       objects.object1 = new cf_imagen( imgObj.getDirectory(),
			                                        names.name1,
			                                        true );
			       objects.object2 = new cf_imagen( imgObj.getDirectory(),
                                                    names.name2,
                                                    true );
                   objects.object3 = new cf_imagen( imgObj.getDirectory(),
                                                    names.name3,
                                                    true );

			   </cfscript>

	           <p class="alert alert-#message.type#">#message.body#</p>

	           <cfif fileExists( '#objects.object1.getDirectory()##objects.object1.getName()#' )>
				    <h3>Image 1</h3>
				    <img src="images_3/#objects.object1.getName()#" />
				    <ul>
					   <li>Name: #objects.object1.getInfo().name#</li>
					   <li>Width: #objects.object1.getInfo().width# px</li>
					   <li>Height: #objects.object1.getInfo().height# px</li>
					   <li>Directory: #objects.object1.getInfo().directory#</li>
					   <li><a href="#CGI.SCRIPT_NAME#?delete=#objects.object1.getName()#" class="btn btn-danger">Delete image</a></li>
					</ul>
			   </cfif>
			   <cfif fileExists( '#objects.object2.getDirectory()##objects.object2.getName()#' )>
                    <h3>Image 2</h3>
                    <img src="images_3/#objects.object2.getName()#" />
                    <ul>
                       <li>Name: #objects.object2.getInfo().name#</li>
                       <li>Width: #objects.object2.getInfo().width# px</li>
                       <li>Height: #objects.object2.getInfo().height# px</li>
                       <li>Directory: #objects.object2.getInfo().directory#</li>
                    </ul>
               </cfif>
			<cfif fileExists( '#objects.object3.getDirectory()##objects.object3.getName()#' )>
                    <h3>Image 3</h3>
                    <img src="images_3/#objects.object3.getName()#" />
                    <ul>
                       <li>Name: #objects.object3.getInfo().name#</li>
                       <li>Width: #objects.object3.getInfo().width# px</li>
                       <li>Height: #objects.object3.getInfo().height# px</li>
                       <li>Directory: #objects.object3.getInfo().directory#</li>
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
	                        <label for="name">Name</label>
	                        <input type="text" name="name" id="name" class="form-control" placeholder="Name of the image i.e myNewImage.jpg" />
	                    </div>
	                    <div class="form-group">
	                        <label for="width1">Width 1</label>
	                        <input type="text" name="width1" id="width1" class="form-control" placeholder="Width of the first saved image in pixels" />
	                    </div>
	                    <div class="form-group">
                            <label for="width1">Width 2</label>
                            <input type="text" name="width2" id="width2" class="form-control" placeholder="Width of the second saved image in pixels" />
                        </div>
						<div class="form-group">
                            <label for="width1">Width 3</label>
                            <input type="text" name="width3" id="width3" class="form-control" placeholder="Width of the third saved image in pixels" />
                        </div>

	                    <button name="submit" class="btn btn-success">Upload</button>
	                </form>
	            </div>
	        </div>
		</div>

	</body>
</html>
</cfoutput>