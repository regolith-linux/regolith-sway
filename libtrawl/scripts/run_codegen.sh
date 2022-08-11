#!/bin/sh
gdbus-codegen  --body --output $2 $1
gdbus-codegen  --header --output $3 $1 
