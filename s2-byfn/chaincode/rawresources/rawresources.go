package main

import (
	"fmt"
	"time"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	pb "github.com/hyperledger/fabric/protos/peer"
)

type RawResourceType struct {
	ID   int64  `json:"id"`
	Name string `json:"name"`
}

// RawResource - raw resource
type RawResource struct {
	ID          int64      `json:"id"`
	Name        string     `json:"name"`
	TypeID      int        `json:"type_id"`
	Weight      float32    `json:"weight"` // in lbs'
	ArrivalTime *time.Time `json:"arrival_time"`
	Timestamp   *time.Time `json:"timestamp"`
}

type Chaincode struct {
}

func (c *Chaincode) Init(stub shim.ChaincodeStubInterface) pb.Response {
	return shim.Success(nil)
}

func (c *Chaincode) Invoice(stub shim.ChaincodeStubInterface) pb.Response {

	function, args := stub.GetFunctionAndParameters()

	switch function {
	case "store":
		return Store(stub, args)
	case "index":
		return Index(stub, args)
	default:
		return shim.Error("Available Functions: ")
	}

}

func main() {
	if err := shim.Start(new(Chaincode)); err != nil {
		fmt.Printf("Error starting chaincode: %s", err)
	}
}
