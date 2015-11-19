/**
********************************************************************************
*@author: Angel Chrystian Torres
*@Date: 12/10/2015
********************************************************************************
*/
component{
    // Application properties
    this.name = hash( getDirectoryFromPath( getCurrentTemplatePath() ) );

     if( SERVER.COLDFUSION.productName eq 'ColdFusion Server' ){
        this.mappings[ '/' ] = getDirectoryFromPath( expandPath( '../') );
     }


    // request start
    public boolean function onRequestStart(String targetPage){

        if( not findNoCase('index', CGI.SCRIPT_NAME ) ){
	        writeoutput('
	            <div class="container">
	                <a href="index.cfm">
	                    <span class="glyphicon glyphicon-th-list" aria-hidden="true"></span>
	                    Return to index
	                </a>

	                <h1>cf_imagen Examples.</h1>
	            </div>
	        ');
        }

        return true;
    }

    function onRequestEnd(){
    	writeoutput('
    	    <div class="container" style="margin-top:50px;">
			    <div class="row">
				    <div class="col-md-3 bg-success">
					    Download Source
					</div>
					<div class="col-md-6 bg-success">
	                    <strong><a href="https://github.com/angel-chrystian/cf_imagen" target="_blank">https://github.com/angel-chrystian/cf_imagen</a></strong>
	                </div>
			    </div>
			    <div class="row">
	                <div class="col-md-3 bg-success">
	                    More libraries and interesting stuff
	                </div>
	                <div class="col-md-6 bg-success">
	                    <strong><a href="http://elangelito.mx" target="_blank">https://elangelito.mx</a></strong><br />
	                </div>
	            </div>
	            <div class="row">
	                <div class="col-md-6">
                       <small>&copy; Copyright elangelito.mx 2015</small>
                    </div>
				</div>
			</div>
    	');
    }


}
