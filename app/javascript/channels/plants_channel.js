import consumer from "./consumer"

consumer.subscriptions.create("PlantsChannel", {
  connected() {
    console.log("🌿 Connected to the plants channel")
  },

  disconnected() {
    console.log("🌿 Disconnected from the plants channel")
  },

  received(data) {
    console.log("🌿 Received data from plants channel:", data)
    
    // Update the last update timestamp in the debug panel
    const timestamp = new Date().toLocaleTimeString();
    const debugElement = document.getElementById('last-update');
    if (debugElement) {
      debugElement.textContent = `${timestamp} - Plant: ${data.plant_id}`;
    }
    
    // Find the plant element to update
    const plantElement = document.getElementById(data.dom_id);
    if (plantElement) {
      try {
        // Create a temporary div to hold the new HTML
        const tempDiv = document.createElement('div');
        tempDiv.innerHTML = data.html;
        
        // Get the first element from the parsed HTML (our turbo-frame)
        const newPlantElement = tempDiv.firstElementChild;
        
        if (newPlantElement) {
          // Replace the old element with the new one
          plantElement.replaceWith(newPlantElement);
          
          // Flash the row
          const row = document.querySelector(`#${data.dom_id} tr`);
          if (row) {
            row.classList.add('flash-highlight');
            setTimeout(() => {
              row.classList.remove('flash-highlight');
            }, 1500);
          }
          
          console.log("🌿 Plant updated successfully");
        } else {
          console.error("❌ No valid element found in the received HTML");
          console.debug("Received HTML:", data.html);
        }
      } catch (error) {
        console.error("❌ Error updating plant element:", error);
      }
    } else {
      console.error("❌ Could not find plant element with ID:", data.dom_id);
      console.debug("All turbo-frames on page:", document.querySelectorAll("turbo-frame").length);
      console.debug("DOM IDs on page:", Array.from(document.querySelectorAll("[id]")).map(el => el.id));
    }
  }
}) 