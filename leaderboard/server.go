package main


import (
	"database/sql"
	_ "github.com/mattn/go-sqlite3"
	"net/http"
)


var leaderboardDB *sql.DB

func getLeaderboardHandler(w http.ResponseWriter, r *http.Request) {


}


func newHighscoreHandler(w http.ResponseWriter, r *http.Request) {

}



func main () {
	var err error
	leaderboardDB, err = sql.Open("sqlite3", "leaderboard.db")
	if err != nil { panic(err) }

	httpServer := http.NewServeMux()
	httpServer.HandleFunc("/leaderboard", getLeaderboardHandler)
	httpServer.HandleFunc("/highscore", newHighscoreHandler)

	err = http.ListenAndServe(":10002", httpServer)
	if err != nil { panic(err) }



}

