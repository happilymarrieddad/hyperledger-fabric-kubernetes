package router

import (
	"net/http"

	"github.com/gorilla/mux"

	V1Router "github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s3-services/backend/routes/v1"
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

	for name, pack := range V1Router.GetRoutes() {
		r.AttachSubRouterWithMiddleware(name, pack.Routes, pack.Middleware)
	}

	return r
}
