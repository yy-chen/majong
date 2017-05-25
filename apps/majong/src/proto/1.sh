#!/usr/bin/env bash

cp /Users/cyy/project/proto/*.proto ./

../../../../_build/default/lib/gpb/bin/protoc-erl -I. ./majong_pb.proto

mv *.hrl ../include

rm *.proto
