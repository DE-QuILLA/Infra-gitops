echo "I'am here\n"
echo $(pwd)

cd ./terraform && ./bootstrap_infra.sh

sleep 5

cd ../deploy && ./deploy_stacks.sh
