import streamlit as st
import sqlite3
import pandas as pd

# --- DATABASE SETUP ---
conn = sqlite3.connect('scores.db')
c = conn.cursor()
c.execute('''
    CREATE TABLE IF NOT EXISTS scores (
        id INTEGER PRIMARY KEY,
        date TEXT,
        location TEXT,
        game TEXT,
        dwad INTEGER,
		brit INTEGER
    )
''')
conn.commit()

# --- DATA ENTRY ---
st.title("💑 Game Score Tracker")
with st.form('add_score'):
    date = st.date_input("Date")
    location = st.text_input("Location")
    game = st.selectbox("Game", ['Pickleball', 'Cornhole', 'Beer Pong'])
    dwad = st.number_input("D-Wads Score", min_value=0)
    brit = st.number_input("Brits Score", min_value=0)
    submitted = st.form_submit_button("Add Score")
    if submitted:
        c.execute("INSERT INTO scores (date,location,game,dwad,brit) VALUES (?,?,?,?,?)",
                  (date,location,game,dwad,brit))
        conn.commit()
        st.success("Score added!")

# --- VIEW / ANALYZE ---
df = pd.read_sql_query("SELECT * FROM scores", conn)
total_games = len(df)
total_dwad = df['dwad'].sum()
total_brit = df['brit'].sum()

if not df.empty:
    st.write("Saved Scores:", df)
    st.header("Score Summary")
    st.write(f"Total Games Played: {total_games}")
    st.write(f"Total D-Wads Score: {total_dwad}")
    st.write(f"Total Brits Score: {total_brit}")
    st.line_chart(df.pivot_table(index='date', columns='game', values='dwad', aggfunc='sum').fillna(0))
    st.download_button("Export CSV", df.to_csv(index=False), "scores.csv")
else:
    st.info("No scores yet, add your first entry!")

conn.close()
