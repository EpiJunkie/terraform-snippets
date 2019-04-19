FROM amazonlinux:2017.03

LABEL "com.fc.vendor"="Lead Street Security"
LABEL version="1.0"
LABEL description="Builds a Lambda Layer zip containing specified unix binaries."

ADD build_wrapper.sh .
ADD build_python36_modules_lambda_layer.sh .
ADD build_terraform_lambda_layer_zip.sh .
ADD build_unix_binary_lambda_layer_zip.sh .
RUN chmod +x build_wrapper.sh
RUN chmod +x build_python36_modules_lambda_layer.sh
RUN chmod +x build_terraform_lambda_layer_zip.sh
RUN chmod +x build_unix_binary_lambda_layer_zip.sh
CMD ./build_wrapper.sh $BUILD_TYPE $YUM_PACKAGES_TO_INCLUDE && printf "Run following commands to copy built zip file and remove container: \n\ndocker cp `cat /proc/self/cgroup | grep "cpu:/docker" | cut -d/ -f3`:`ls /*.zip` \"./$LAMBDA_LAYER_ZIP_PACKAGE_NAME\" && docker rm `cat /proc/self/cgroup | grep "cpu:/docker" | cut -d/ -f3`\n"
