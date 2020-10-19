package hyperledger

import (
	"github.com/pkg/errors"

	sdkchannel "github.com/hyperledger/fabric-sdk-go/pkg/client/channel"
	mspclient "github.com/hyperledger/fabric-sdk-go/pkg/client/msp"
	"github.com/hyperledger/fabric-sdk-go/pkg/client/resmgmt"
	"github.com/hyperledger/fabric-sdk-go/pkg/common/errors/retry"
	"github.com/hyperledger/fabric-sdk-go/pkg/core/config"
	"github.com/hyperledger/fabric-sdk-go/pkg/fabsdk"
)

type orgClient struct {
	User          string
	Org           string
	ChannelClient *sdkchannel.Client
}

type clientList map[string]*orgClient

type Clients struct {
	Name       string
	ConfigPath string
	List       clientList
}

func (c *Clients) AddClient(user string, org string, channel string) (*orgClient, error) {
	if val, ok := c.List[org+channel]; ok {
		return val, errors.New("client already exists")
	}

	sdk, err := fabsdk.New(config.FromFile(c.ConfigPath))
	if err != nil {
		return nil, errors.WithMessage(err, "unable to get config from file")
	}

	resourceManagerClientContext := sdk.Context(
		fabsdk.WithUser(user),
		fabsdk.WithOrg(org),
	)

	if _, err := resmgmt.New(resourceManagerClientContext); err != nil {
		return nil, errors.WithMessage(err, "unable to get user resource management")
	}

	mspclient, err := mspclient.New(
		sdk.Context(),
		mspclient.WithOrg(org),
	)

	if _, err = mspclient.GetSigningIdentity(user); err != nil {
		return nil, errors.WithMessage(err, "unable to get signing identity")
	}

	clientContext := sdk.ChannelContext(
		channel,
		fabsdk.WithUser(user),
		fabsdk.WithOrg(org),
	)

	channelClient, err := sdkchannel.New(clientContext)
	if err != nil {
		return nil, errors.WithMessage(err, "unable to create client from channel context")
	}

	c.List[org+channel] = &orgClient{
		User:          user,
		Org:           org,
		ChannelClient: channelClient,
	}

	return c.List[org+channel], nil
}

func (c *Clients) GetClient(org, channel string) (*orgClient, error) {
	if val, ok := c.List[org+channel]; ok {
		return val, nil
	}

	return nil, errors.New("no client for org " + org)
}

func (c *Clients) Query(org string, channel string, chaincode string, fcn string, args [][]byte) (ret []byte, err error) {
	client, err := c.GetClient(org, channel)
	if err != nil {
		return
	}

	resp, err := client.ChannelClient.Query(
		sdkchannel.Request{
			ChaincodeID: chaincode,
			Fcn:         fcn,
			Args:        args,
		},
		sdkchannel.WithTargetEndpoints("peer0-"+org+"-service"),
		sdkchannel.WithRetry(retry.DefaultChannelOpts),
	)

	ret = resp.Payload

	return
}

func (c *Clients) Invoke(org string, channel string, chaincode string, fcn string, args [][]byte) (ret []byte, err error) {
	client, err := c.GetClient(org, channel)
	if err != nil {
		return
	}

	transientDataMap := make(map[string][]byte)
	transientDataMap["result"] = []byte("Transient Data in invoke func")

	resp, err := client.ChannelClient.Execute(
		sdkchannel.Request{
			ChaincodeID:  chaincode,
			Fcn:          fcn,
			Args:         args,
			TransientMap: transientDataMap,
		},
		sdkchannel.WithTargetEndpoints("peer0-"+org+"-service"),
		sdkchannel.WithRetry(retry.DefaultChannelOpts),
	)

	ret = resp.Payload

	return
}

func NewClientMap(name string, configPath string) *Clients {
	clients := new(Clients)

	clients.Name = name
	clients.ConfigPath = configPath
	clients.List = make(clientList)

	return clients
}
