#!/usr/bin/python
#-*- utf-8 -*-
import os
import cv2
import argparse


def concat_subdir(data_root, fold, N):
    # fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    fourcc = cv2.VideoWriter_fourcc(*'avc1')
    fps = 24

    imgs = sorted(os.listdir(os.path.join(data_root,fold)))
    x,y,_ = cv2.imread(os.path.join(data_root,fold,imgs[0])).shape
    print(x,y)
    video_writer = cv2.VideoWriter(os.path.join(data_root,fold+".mp4"),fourcc,fps,(y,x))

    for i in range(0,len(imgs),N+1):
        frame = cv2.imread(os.path.join(data_root,fold,imgs[i]))
        cv2.resize(frame,(y,x))
        cv2.imshow('frame',frame)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break
        video_writer.write(frame)
    video_writer.release()


def concat_all(data_root,N):
    folders = os.listdir(data_root)
    folders = [ fold for fold in folders if os.path.isdir(os.path.join(data_root,fold))]
    for fold in folders:
        concat_subdir(data_root,fold, N)

def parse_arg():
    parser = argparse.ArgumentParser()
    parser.add_argument('-data_root',type=str,default='/home/tony/Videos/out')
    parser.add_argument('-N',type=int,default=0)
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_arg()
    concat_all(args.data_root,args.N)
