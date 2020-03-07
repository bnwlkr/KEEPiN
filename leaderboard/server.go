package main


import (
	"log"
	"os"
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
	w.Header().Set("Content-Type", "application/json")
	w.Write(jsonBytes)
}


func newHighscoreHandler(w http.ResponseWriter, r *http.Request) {
	username := r.FormValue("username")
	highscore := r.FormValue("highscore")
	if username == "" || highscore == "" {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte("Invalid form parameters"))
		return
	}
	_, err := leaderboardDB.Exec("update highscores set highscore=? where username=?", highscore, username)
	if err != nil {
		log.Println(err)
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("Unable to update user highscore"))
	}
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("Successfully updated highscore"))
}

func existsUser(username string) bool {
	var exists bool
	err := leaderboardDB.QueryRow("select exists(select 1 from highscores where username=?)", username).Scan(&exists)
	if err != nil { log.Println(err); return true; }
	return exists
}

func existsUserHandler(w http.ResponseWriter, r *http.Request) {
	username := r.FormValue("username")
	if existsUser(username) {
		w.Write([]byte("true"))
	} else {
		w.Write([]byte("false"))
	}
}

func newUserHandler(w http.ResponseWriter, r *http.Request) {
	username := r.FormValue("username")
	highscore := r.FormValue("highscore")
	if username == "" || highscore == "" {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte("Invalid form parameters"))
		return
	}
	_, err := leaderboardDB.Exec("insert into highscores (username, highscore) values (?, ?)", username, highscore)
	if err != nil { log.Println(err); w.WriteHeader(http.StatusInternalServerError); return; }
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("Successfully created user"))
}


func main () {
	var err error
	leaderboardDB, err = sql.Open("sqlite3", os.Getenv("KEEPIN_LEADERBOARD_PATH"))
	if err != nil { panic(err) }

	http.HandleFunc("/leaderboard", getLeaderboardHandler)
	http.HandleFunc("/highscore", newHighscoreHandler)
	http.HandleFunc("/newuser", newUserHandler)
	http.HandleFunc("/existsuser", existsUserHandler)

	err = http.ListenAndServe("localhost:10002", nil)
	if err != nil { panic(err) }
}

