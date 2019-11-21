package router

import (
	"net/http"
	"os"

	"github.com/gorilla/mux"

	V1Router "github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s5-connecting-everything/backend/routes/v1"
	"github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s5-connecting-everything/backend/hyperledger"
)

const (
	staticDir = "/static/"
)

type Service interface {
	GetRawRouter() *mux.Router
}

func GetRouter() Service {
	r := Router{
		RawRouter: mux.NewRouter().StrictSlash(true),
	}

	configPath := os.Getenv("HYPERLEDGER_CONFIG_PATH")

	if len(configPath) == 0 {
		panic("ENV var 'HYPERLEDGER_CONFIG_PATH' is not set. unable to connect to network")
	}

	clients := hyperledger.NewClientMap(
		"test-network",
		configPath,
	)

	_, err := clients.AddClient(
		"Admin",
		"org1",
		"mainchannel",
	)
	if err != nil {
		panic(err)
	}

	r.RawRouter.
		PathPrefix(staticDir).
		Handler(http.StripPrefix(staticDir, http.FileServer(http.Dir("."+staticDir))))

	for _, route := range GetRoutes() {
		r.RawRouter.
			Methods(route.Method).
			Path(route.Pattern).
			Name(route.Name).
			Handler(route.HandlerFunc)
	}

	for name, pack := range V1Router.GetRoutes(clients) {
		r.AttachSubRouterWithMiddleware(name, pack.Routes, pack.Middleware)
	}

	return r
}
