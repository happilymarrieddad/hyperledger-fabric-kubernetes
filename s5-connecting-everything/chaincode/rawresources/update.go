package main

import (
	"github.com/hyperledger/fabric/core/chaincode/shim"
	pb "github.com/hyperledger/fabric/protos/peer"
)

func Update(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	if len(args) != 2 {
		return shim.Error("update needs an ID and an item stringified as the first and second arguments")
	}

	stub.PutState(args[0], []byte(args[1]))

	rawResource, err := stub.GetState(args[0])
	if err != nil {
		return shim.Error("unable to update the raw resource: " + err.Error())
	}

	return shim.Success(rawResource)
}
