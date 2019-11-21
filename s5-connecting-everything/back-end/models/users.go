package models

type Users []User

type User struct {
	ID        string `json:"id"`
	FirstName string `json:"first_name"`
	LastName  string `json:"last_name"`
	Email     string `json:"email"`
	Password  string `json:"password"`
}

func NewUser(firstName string, lastName string, email string, password string) (user *User, err error) {
	user = new(User)

	id, err := genUUID()
	if err != nil {
		return
	}

	user.ID = id
	user.FirstName = firstName
	user.LastName = lastName
	user.Email = email
	if user.Password, err = EncryptPassword(password); err != nil {
		return
	}

	return
}
