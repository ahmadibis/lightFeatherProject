import React, { useEffect, useState } from 'react'
import './App.css';
import API_URL from './config'

function App() {
  const [successMessage, setSuccessMessage] = useState() 
  const [failureMessage, setFailureMessage] = useState() 

  useEffect(() => {
    const getId = async () => {
      try {
        const resp = await fetch(API_URL)
        setSuccessMessage((await resp.json()).id)
      }
      catch(e) {
        setFailureMessage(e.message)
      }
    }
    getId()
  })

  return (
    <div className="App">
      {!failureMessage && !successMessage ? 'Fetching...' : null}
      {failureMessage ? failureMessage : null}
      {successMessage ? (
        <div>
          <span>SUCCESS</span> {successMessage}
        </div>
      ) : null}
    </div>
  );
}

export default App;
