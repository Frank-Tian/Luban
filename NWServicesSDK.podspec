# Version:54
# AppKey:xxxx

Pod::Spec.new do |spec|
	spec.name		= "NWServicesSDK"
	spec.version	= "54.0"
	spec.summary	= "NWServicesSDK"
	spec.homepage	= "https://code.xxxx.cn"
	spec.license	= { :type => "MIT", :file => "FILE_LICENSE" }
	spec.authors	= {"nvwa" => ""}
	spec.platform	= :ios, "9.0"
 	spec.source		= {:git => "" }

	spec.dependency 'NWBaseComponent','0.1.2'
	spec.dependency 'NWConnectionComponent','0.4.0'



end