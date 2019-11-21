package main

import (
	"encoding/json"
	"time"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	pb "github.com/hyperledger/fabric/protos/peer"
)

func Store(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	if len(args) != 1 {
		return shim.Error("store needs an item that is stringified as the first and only argument")
	}

	var item RawResource
	if err := json.Unmarshal([]byte(args[0]), &item); err != nil {
		return shim.Error(err.Error())
	}

	if len(item.ID) == 0 {
		return shim.Error("ID is required to store raw resource")
	}

	if item.Weight == 0 {
		return shim.Error("Weight is required to store raw resource")
	}

	if len(item.Name) == 0 {
		return shim.Error("Name is required to store raw resource")
	}

	t := time.Now()
	item.Timestamp = &t
	item.Visible = true

	itemAsBytes, err := json.Marshal(item)
	if err != nil {
		return shim.Error(err.Error())
	}

	stub.PutState(item.ID, itemAsBytes)

	rawAsset, err := stub.GetState(item.ID)
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success(rawAsset)
}
