package router

import (
	"github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s5-connecting-everything/backend/models"
	HomeHandler "github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s5-connecting-everything/backend/routes/home"
	StatusHandler "github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s5-connecting-everything/backend/routes/status"
)

func GetRoutes() models.Routes {
	return models.Routes{
		models.Route{Name: "Home", Method: "GET", Pattern: "/", HandlerFunc: HomeHandler.Index},
		models.Route{Name: "Status", Method: "GET", Pattern: "/status", HandlerFunc: StatusHandler.Index},
	}
}
