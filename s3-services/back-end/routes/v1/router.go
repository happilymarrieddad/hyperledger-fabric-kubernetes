package v1

import (
	"net/http"

	"github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s3-services/backend/models"
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
				models.Route{Name: "UsersIndex", Method: "GET", Pattern: "/users", HandlerFunc: UsersHandler.Index()},
				models.Route{Name: "UsersStore", Method: "POST", Pattern: "/users", HandlerFunc: UsersHandler.Store()},
				models.Route{Name: "UsersReplace", Method: "PUT", Pattern: "/users/{id}", HandlerFunc: UsersHandler.Update()},
				models.Route{Name: "UsersUpdate", Method: "PATCH", Pattern: "/users/{id}", HandlerFunc: UsersHandler.Update()},
				models.Route{Name: "UsersDestroy", Method: "DELETE", Pattern: "/users/{id}", HandlerFunc: UsersHandler.Destroy()},
			},
		},
	}
}
