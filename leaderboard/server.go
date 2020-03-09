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

type Player struct {
	Username string		`json:"username"`
	Highscore int		`json:"highscore"`
	Region string		`json:"region"`
}

func getLeaderboardHandler(w http.ResponseWriter, r *http.Request) {
	if r.FormValue("secret") != os.Getenv("KEEPIN_SECRET") { log.Println("Request with invalid secret"); return }
	playerRows, err := leaderboardDB.Query("select username, highscore, region from Players")
	if err != nil { log.Println(err); return }
	var players []Player
	for playerRows.Next() {
		var player Player
		err := playerRows.Scan(&player.Username, &player.Highscore, &player.Region)
		if err != nil { log.Println(err) }
		players = append(players, player)
	}
	jsonBytes, err := json.Marshal(players)
	if err != nil { log.Println(err); return }
	w.Header().Set("Content-Type", "application/json")
	w.Write(jsonBytes)
}


func existsUser(username string) bool {
	var exists bool
	err := leaderboardDB.QueryRow("select exists(select 1 from Players where username=?)", username).Scan(&exists)
	if err != nil { log.Println(err); return true; }
	return exists
}

func existsUserHandler(w http.ResponseWriter, r *http.Request) {
	if r.FormValue("secret") != os.Getenv("KEEPIN_SECRET") { log.Println("Request with invalid secret"); return }
	username := r.FormValue("username")
	if existsUser(username) {
		w.Write([]byte("true"))
	} else {
		w.Write([]byte("false"))
	}
}

func highscoreHandler(w http.ResponseWriter, r *http.Request) {
	if r.FormValue("secret") != os.Getenv("KEEPIN_SECRET") { log.Println("Request with invalid secret"); return }
	username := r.FormValue("username")
	highscore := r.FormValue("highscore")
	region := r.FormValue("region")
	if username == "" || highscore == "" {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte("Invalid form parameters"))
		return
	}
	if existsUser(username) {
		_, err := leaderboardDB.Exec("update Players set highscore=?, region=? where username=?", highscore, region, username)
		if err != nil { log.Println(err); w.WriteHeader(http.StatusInternalServerError); return; }
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("Successfully updated highscore"))
	} else {
		_, err := leaderboardDB.Exec("insert into Players (username, highscore, region) values (?, ?, ?)", username, highscore, region)
		if err != nil { log.Println(err); w.WriteHeader(http.StatusInternalServerError); return; }
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("Successfully created user"))
	}
}


func main () {
	var err error
	leaderboardDB, err = sql.Open("sqlite3", os.Getenv("KEEPIN_LEADERBOARD_PATH"))
	if err != nil { panic(err) }

	http.HandleFunc("/leaderboard", getLeaderboardHandler)
	http.HandleFunc("/highscore", highscoreHandler)
	http.HandleFunc("/existsuser", existsUserHandler)

	err = http.ListenAndServe("localhost:10002", nil)
	if err != nil { panic(err) }
}

