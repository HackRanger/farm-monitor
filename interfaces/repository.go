package interfaces

type DbHandler interface {
	Execute(statement string)
	Query(statement string) Row
}

type Row interface {
	Scan(dest ...interface{})
	Next() bool
}

type DbRepo struct {
	dbHandlers map[string]DbHandler
	dbHandler  DbHandler
}

type DbAlertRepo DbRepo

func NewDbAlertRepo(dbHandlers map[string]DbHandler) *DbAlertRepo {
	dbUserRepo := new(DbAlertRepo)
	dbUserRepo.dbHandlers = dbHandlers
	dbUserRepo.dbHandler = dbHandlers["DbAlertRepo"]
	return dbUserRepo
}
