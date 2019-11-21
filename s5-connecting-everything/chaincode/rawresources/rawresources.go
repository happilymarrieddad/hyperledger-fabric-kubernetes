package main

import (
	"fmt"
	"time"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	pb "github.com/hyperledger/fabric/protos/peer"
)

type RawResourceType struct {
	ID   string `json:"id"`
	Name string `json:"name"`
}

// RawResource - raw resource
type RawResource struct {
	ID          string     `json:"id"`
	Name        string     `json:"name"`
	TypeID      string     `json:"type_id"`
	Weight      float32    `json:"weight"` // in lbs'
	ArrivalTime *time.Time `json:"arrival_time"`
	Timestamp   *time.Time `json:"timestamp"`
	Visible     bool       `json:"visible"`
}

type Chaincode struct {
}

func (c *Chaincode) Init(stub shim.ChaincodeStubInterface) pb.Response {
	return shim.Success(nil)
}

func (c *Chaincode) Invoke(stub shim.ChaincodeStubInterface) pb.Response {

	function, args := stub.GetFunctionAndParameters()

	switch function {
	case "store":
		return Store(stub, args)
	case "update":
		return Update(stub, args)
	case "index":
		return Index(stub, args)
	case "queryString":
		return QueryString(stub, args)
	default:
		return shim.Error("Available Functions: Store, Update, Index, QueryString")
	}

}

func (c *Chaincode) Query(stub shim.ChaincodeStubInterface) pb.Response {

	function, args := stub.GetFunctionAndParameters()

	switch function {
	case "index":
		return Index(stub, args)
	case "queryString":
		return QueryString(stub, args)
	default:
		return shim.Error("Available Functions: Index, QueryString")
	}

}

func main() {
	if err := shim.Start(new(Chaincode)); err != nil {
		fmt.Printf("Error starting chaincode: %s", err)
	}
}
