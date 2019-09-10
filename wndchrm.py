#!/usr/bin/python

##usage python wndchrm.py -t <training data> [-a <analytical data> -o <output folder> -n <output name>] 

import os
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("-t", "--training", help="Training data",nargs='?')
parser.add_argument("-a", "--analysis", help="Analysis data",nargs='?')
parser.add_argument("-o", "--output", help="Output folder",nargs='?',default="wndchrm_output")
parser.add_argument("-n", "--name", help="Output name",nargs='?')
args= parser.parse_args()

#Set output folder
name=args.name
if args.name is None:
    name=args.training
    if args.analysis is not None:
        name=name+"_"+args.analysis

out=args.output+"/"+name

exists=os.path.exists(args.output+"/"+args.training)

cmd="mkdir -p "+out
os.system(cmd)

##Check if training set exists
if exists:
    cmd="ln -s $PWD/"+args.output+"/"+args.training+"/"+args.training+".* "+out+"/"
    os.system(cmd)
else:
    ##Run wndchrm training
    cmd="wndchrm train -m -l "+args.training+" "+out+"/"+args.training+".fit"
    os.system(cmd)

    ##Test the training set 30 times
    cmd="wndchrm test -m -l -n30 "+out+"/"+args.training+".fit "+out+"/"+args.training+".html"
    os.system(cmd)

if args.analysis is not None:
    ##Run classification
    cmd="wndchrm classify -l "+out+"/"+args.training+".fit "+args.analysis+" > "+out+"/"+args.analysis+".csv"
    os.system(cmd)

    ##Parse CSV file to get plotting columns
    cmd="python /usr/local/bin/csv_parse.py "+out+"/"+args.analysis+".csv"
    os.system(cmd)

    ##Get R output
    cmd="R --no-save --args "+out+" "+args.analysis+" < /usr/local/bin/wndchrm_to_phy.R"
    os.system(cmd)

print "Complete"
