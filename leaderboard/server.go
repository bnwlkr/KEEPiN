package main


import (
	"log"
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
	} else {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("Successfully updated highscore"))
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
	var exists bool
	err := leaderboardDB.QueryRow("select exists(select 1 from highscores where username=?)", username).Scan(&exists)
	if err != nil { panic(err) }
	if !exists {
		_, err := leaderboardDB.Exec("insert into highscores (username, highscore) values (?, ?)", username, highscore)
		if err != nil { panic(err) }
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("Successfully created user"))
	} else {
		w.WriteHeader(http.StatusConflict) // 409
		w.Write([]byte("Username already exists"))
	}
}

func main () {
	var err error
	leaderboardDB, err = sql.Open("sqlite3", "leaderboard.db")
	if err != nil { panic(err) }

	http.HandleFunc("/leaderboard", getLeaderboardHandler)
	http.HandleFunc("/highscore", newHighscoreHandler)
	http.HandleFunc("/newuser", newUserHandler)

	err = http.ListenAndServe("localhost:10002", nil)
	if err != nil { panic(err) }
}

