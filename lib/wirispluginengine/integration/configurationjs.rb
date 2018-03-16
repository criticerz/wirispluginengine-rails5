class Configurationjs
	def dispatch (request, response, pb)
		response.body =  "// Scripts" + "\r\n" +
		"var _wrs_conf_createimagePath = _wrs_int_path + '/createimage';" "\r\n" +
		"var _wrs_conf_showimagePath = _wrs_int_path + '/showimage';" "\r\n" +
		"var _wrs_conf_editorPath = _wrs_int_path + '/editor';       // Specifies where is the editor HTML code (for popup window)" "\r\n" +
		"var _wrs_conf_CASPath = _wrs_int_path + '/cas';             // Specifies where is the WIRIS cas HTML code (for popup window)" "\r\n" +
		"var _wrs_conf_createimagePath = _wrs_int_path + '/createimage';        // Specifies where is createimage script" "\r\n" +
		"var _wrs_conf_createcasimagePath = _wrs_int_path + '/createcasimage';	// Specifies where is createcasimage script" "\r\n" +
		"var _wrs_conf_getmathmlPath = _wrs_int_path + '/getmathml'; // Specifies where is the getmathml script." "\r\n" +
		"var _wrs_conf_servicePath = _wrs_int_path + '/service'; // Specifies where is the service script." "\r\n"
		conf = pb.getConfiguration()
		response.body = response.body + conf.getJavaScriptConfiguration()

  	end
end