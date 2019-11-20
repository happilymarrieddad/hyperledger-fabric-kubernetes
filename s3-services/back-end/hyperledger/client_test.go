package client

import (
	"fmt"
	"testing"

	"github.com/hyperledger/fabric-sdk-go/pkg/client/channel"
	mspclient "github.com/hyperledger/fabric-sdk-go/pkg/client/msp"
	"github.com/hyperledger/fabric-sdk-go/pkg/client/resmgmt"
	"github.com/hyperledger/fabric-sdk-go/pkg/common/errors/retry"
	"github.com/hyperledger/fabric-sdk-go/pkg/core/config"
	"github.com/hyperledger/fabric-sdk-go/pkg/fabsdk"
)

func Test_Connect_Success(t *testing.T) {

	sdk, err := fabsdk.New(config.FromFile("/home/fusion/Projects/blockchain/hyperledger-fabric-kubernetes/s3-services/back-end/hyperledger/config.yaml"))
	if err != nil {
		t.Fatal(err)
	}

	resourceManagerClientContext := sdk.Context(
		fabsdk.WithUser("Admin"),
		fabsdk.WithOrg("org1"),
	)

	_, err = resmgmt.New(resourceManagerClientContext)
	if err != nil {
		t.Fatal(err)
	}

	mspClient, err := mspclient.New(
		sdk.Context(),
		mspclient.WithOrg("org1"),
	)
	if err != nil {
		t.Fatal(err)
	}

	_, err = mspClient.GetSigningIdentity("Admin")
	if err != nil {
		t.Fatal(err)
	}

	clientContext := sdk.ChannelContext(
		"mainchannel",
		fabsdk.WithUser("Admin"),
		fabsdk.WithOrg("org1"),
	)
	client, err := channel.New(clientContext)
	if err != nil {
		t.Fatal(err)
	}

	// Creation of the client which will enables access to our channel events
	// event, err := event.New(clientContext)
	// if err != nil {
	// 	return errors.WithMessage(err, "failed to create new event client")
	// }

	req := channel.Request{
		ChaincodeID: "rawresources",
		Fcn:         "index",
		Args: [][]byte{
			[]byte(""),
			[]byte(""),
		},
	}

	response, err := client.Query(
		req,
		channel.WithTargetEndpoints("peer0-org1-service"),
		channel.WithRetry(retry.DefaultChannelOpts),
	)
	if err != nil {
		return
	}

	fmt.Println(string(response.Payload))

	fmt.Println("Success!")
}
