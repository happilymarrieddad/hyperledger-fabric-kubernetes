package main

import (
	"encoding/json"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	pb "github.com/hyperledger/fabric/protos/peer"
)

func QueryString(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var items []RawResource

	if len(args) == 0 {
		return shim.Error("query string is required")
	}

	queryString := args[0]

	resultsIterator, err := stub.GetQueryResult(queryString)
	if err != nil {
		return shim.Error(err.Error())
	}

	defer resultsIterator.Close()

	for resultsIterator.HasNext() {

		res, err := resultsIterator.Next()
		if err != nil {
			return shim.Error(err.Error())
		}

		rawItem, err := stub.GetState(res.Key)
		if err != nil {
			return shim.Error(err.Error())
		}

		var item RawResource
		if err = json.Unmarshal(rawItem, &item); err != nil {
			return shim.Error(err.Error())
		}

		items = append(items, item)
	}

	packet, err := json.Marshal(items)
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success(packet)
}
