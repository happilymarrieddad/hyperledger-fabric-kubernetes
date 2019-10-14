package router

import "github.com/gorilla/mux"

type Service interface {
	GetRawRouter() *mux.Router
}

func GetRouter() Service {
	r := Router{
		RawRouter: mux.NewRouter().StrictSlash(true),
	}

	return r
}
