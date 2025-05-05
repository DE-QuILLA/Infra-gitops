echo "I'am here\n"
echo $(pwd)

cd ./terraform && chmod +x deploy_infra.sh && ./deploy_infra.sh

sleep 5

cd ../deploy && ./deploy_stacks.sh
