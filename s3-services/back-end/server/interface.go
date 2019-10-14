package server

type Service interface {
	Init(port int) error
	Start()
}

func NewServer() Service {
	return &Server{}
}
