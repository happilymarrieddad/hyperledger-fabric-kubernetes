package v1

import (
	"net/http"

	"github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s3-services/backend/models"
	RawResourcesHandler "github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s3-services/backend/routes/v1/rawresources"
	RawResourceTypesHandler "github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s3-services/backend/routes/v1/rawresourcetypes"
	UsersHandler "github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s3-services/backend/routes/v1/users"
)

func Middleware() func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			next.ServeHTTP(w, r)
		})
	}
}

func GetRoutes() map[string]models.SubRoutePackage {
	return map[string]models.SubRoutePackage{
		"/v1": {
			Middleware: Middleware(),
			Routes: models.Routes{
				// Users
				models.Route{Name: "UsersIndex", Method: "GET", Pattern: "/users", HandlerFunc: UsersHandler.Index()},
				models.Route{Name: "UsersStore", Method: "POST", Pattern: "/users", HandlerFunc: UsersHandler.Store()},
				models.Route{Name: "UsersReplace", Method: "PUT", Pattern: "/users/{id}", HandlerFunc: UsersHandler.Update()},
				models.Route{Name: "UsersUpdate", Method: "PATCH", Pattern: "/users/{id}", HandlerFunc: UsersHandler.Update()},
				models.Route{Name: "UsersDestroy", Method: "DELETE", Pattern: "/users/{id}", HandlerFunc: UsersHandler.Destroy()},
				// RawResourceTypes
				models.Route{Name: "RawResourceTypesIndex", Method: "GET", Pattern: "/rawresourcetypes", HandlerFunc: RawResourceTypesHandler.Index()},
				models.Route{Name: "RawResourceTypesStore", Method: "POST", Pattern: "/rawresourcetypes", HandlerFunc: RawResourceTypesHandler.Store()},
				models.Route{Name: "RawResourceTypesReplace", Method: "PUT", Pattern: "/rawresourcetypes/{id}", HandlerFunc: RawResourceTypesHandler.Update()},
				models.Route{Name: "RawResourceTypesUpdate", Method: "PATCH", Pattern: "/rawresourcetypes/{id}", HandlerFunc: RawResourceTypesHandler.Update()},
				models.Route{Name: "RawResourceTypesDestroy", Method: "DELETE", Pattern: "/rawresourcetypes/{id}", HandlerFunc: RawResourceTypesHandler.Destroy()},
				// RawResources
				models.Route{Name: "RawResourcesIndex", Method: "GET", Pattern: "/rawresources", HandlerFunc: RawResourcesHandler.Index()},
				models.Route{Name: "RawResourcesStore", Method: "POST", Pattern: "/rawresources", HandlerFunc: RawResourcesHandler.Store()},
				models.Route{Name: "RawResourcesReplace", Method: "PUT", Pattern: "/rawresources/{id}", HandlerFunc: RawResourcesHandler.Update()},
				models.Route{Name: "RawResourcesUpdate", Method: "PATCH", Pattern: "/rawresources/{id}", HandlerFunc: RawResourcesHandler.Update()},
				models.Route{Name: "RawResourcesDestroy", Method: "DELETE", Pattern: "/rawresources/{id}", HandlerFunc: RawResourcesHandler.Destroy()},
				models.Route{Name: "RawResourcesShow", Method: "GET", Pattern: "/rawresources/{id}", HandlerFunc: RawResourcesHandler.Show()},
			},
		},
	}
}
