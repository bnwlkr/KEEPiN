package main


import (
	"log"
	"strings"
	"fmt"
	"encoding/json"
	"database/sql"
	_ "github.com/mattn/go-sqlite3"
	"net/http"
)


var leaderboardDB *sql.DB

type Highscore struct {
	Username string		`json:"username"`
	Highscore int		`json:"highscore"`
}

func getLeaderboardHandler(w http.ResponseWriter, r *http.Request) {
	highscoreRows, err := leaderboardDB.Query("select * from highscores")
	if err != nil { log.Println(err); return }
	var highscores []Highscore
	for highscoreRows.Next() {
		var highscore Highscore
		err := highscoreRows.Scan(&highscore.Username, &highscore.Highscore)
		if err != nil { log.Println(err) }
		highscores = append(highscores, highscore)
	}
	jsonBytes, err := json.Marshal(highscores)
	if err != nil { log.Println(err); return }
	fmt.Fprintf(w, string(jsonBytes));
}


func newHighscoreHandler(w http.ResponseWriter, r *http.Request) {
	err := r.ParseForm()
	if err != nil { log.Println(err) }
	username, hasUsername := r.Form["username"]
	highscore, hasHighscore := r.Form["highscore"]
	if hasHighscore && hasUsername {
		_, err := leaderboardDB.Exec("insert into highscores (username, highscore) values (?, ?)", strings.Join(username, ""), strings.Join(highscore, ""))
		if err != nil { log.Println(err) }
	}
}



func main () {
	var err error
	leaderboardDB, err = sql.Open("sqlite3", "leaderboard.db")
	if err != nil { panic(err) }

	http.HandleFunc("/leaderboard", getLeaderboardHandler)
	http.HandleFunc("/highscore", newHighscoreHandler)

	err = http.ListenAndServe("localhost:10002", nil)
	if err != nil { panic(err) }



}

