#Shanxia
#变量组
LOCAL_DIR=$(pwd)                            #本地目录
PROJECT_DIR=$LOCAL_DIR/${1}                 #工程目录 
SHELL=$(readlink -f "$0")                   #脚本文件
SHELL_DIR=$(dirname $SHELL)                 #脚本路径
SYSTEM_DIR="${PROJECT_DIR}/system/system"   #系统目录
ApkTool="java -jar $SHELL_DIR/apktool.jar"  #ApkTool位置
REPLACE="$SHELL_DIR/replace"

sudo rm -rf $SHELL_DIR/services
$ApkTool d -r -o $SHELL_DIR/services $SYSTEM_DIR/framework/services.jar -f
Crack_File=$(find $SHELL_DIR/services/ -type f -name '*.smali' 2>/dev/null | xargs grep -rl '.method private checkSystemSelfProtection(Z)V' | sed 's/^\.\///' | sort)
sed -i '/^.method private checkSystemSelfProtection(Z)V/,/^.end method/{//!d}' $Crack_File
sed -i -e '/^.method private checkSystemSelfProtection(Z)V/a\    .locals 1\n\n    return-void' $Crack_File
$ApkTool b -o $SYSTEM_DIR/framework/services.jar $SHELL_DIR/services -f
${su}rm -rf $SHELL_DIR/services
${su}chown -hR $USER:$USER $SYSTEM_DIR/framework/services.jar
${su}chmod -R a+rwX $SYSTEM_DIR/framework/services.jar

echo -en "\n卡米破解结束 开始替换文件与删除文件...\n"
for files in $(cat $SHELL_DIR/FileDeletes.txt ); do
	if [ -e $PROJECT_DIR/system/$files ]; then
		echo "rm -rf $PROJECT_DIR/system/$files"
		rm -rf $PROJECT_DIR/system/$files
	elif [ -e $PROJECT_DIR/$files ]; then
		echo "rm -rf $PROJECT_DIR/$files"
		rm -rf $PROJECT_DIR/$files
	fi
done

#替换文件
cp -ar $REPLACE/MiuiPackageInstaller.apk $PROJECT_DIR/system/system/priv-app/MiuiPackageInstaller/
cp -ar $REPLACE/MIUIFileExplorer.apk $PROJECT_DIR/system/system/app/MIUIFileExplorer/
cp -ar $REPLACE/auto-install.json $PROJECT_DIR/system/system/etc/
cp -ar $REPLACE/magisk_env $PROJECT_DIR/META-INF/
cp -ar $REPLACE/bootanimation.zip $PROJECT_DIR/system/system/media/
cp -ar $REPLACE/logo.img $PROJECT_DIR/firmware-update/
cp -ar $REPLACE/perfinit.conf $PROJECT_DIR/system/system/etc/


#Magisk
sed -i '$a package_extract_file("META-INF/magisk_env", "/tmp/magisk_env");' $PROJECT_DIR/META-INF/com/google/android/updater-script
sed -i '$a run_program("/sbin/unzip", "/tmp/magisk_env", "META-INF/com/google/android/update-binary", "-d", "/tmp");' $PROJECT_DIR/META-INF/com/google/android/updater-script
sed -i '$a run_program("/sbin/sh", "/tmp/META-INF/com/google/android/update-binary", "dummy", "1", "/tmp/magisk_env");' $PROJECT_DIR/META-INF/com/google/android/updater-script


echo -en "\n程序结束 按回车退出...\n"
read 