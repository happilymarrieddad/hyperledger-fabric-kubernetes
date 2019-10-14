package router

import "github.com/gorilla/mux"

type Router struct {
	RawRouter *mux.Router
}

func (r Router) GetRawRouter() *mux.Router {
	return r.RawRouter
}
