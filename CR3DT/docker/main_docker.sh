#! /bin/bash

#dataset path as arg
data_dir=$1

docker run --tty \
    -d \
    --interactive \
    --volume $data_dir:/data \
    --volume $data_dir/checkpoints:/root/cr3dt/checkpoints \
    --ipc=host\
    --network=host \
    --privileged \
    --name main_cr3dt \
    cr3dt_detector \
    /bin/bash
