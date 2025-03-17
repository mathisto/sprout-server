import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Flash controller connected to element:", this.element);
    
    // Apply flash immediately if this is a new element
    this.flash();
    
    // Watch for changes to this element
    try {
      this.observer = new MutationObserver((mutations) => {
        console.log("Mutation detected:", mutations);
        this.flash();
      });
      
      this.observer.observe(this.element, { 
        childList: true,
        subtree: true,
        characterData: true,
        attributes: true
      });
      
      console.log("✅ MutationObserver initialized for:", this.element);
    } catch (error) {
      console.error("❌ Error setting up MutationObserver:", error);
    }
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect();
      console.log("✅ MutationObserver disconnected");
    }
  }

  flash() {
    try {
      // Add flash class
      this.element.classList.add('flash-highlight');
      console.log("✅ Flash applied to element:", this.element);
      
      // Remove the class after animation completes
      setTimeout(() => {
        this.element.classList.remove('flash-highlight');
      }, 1500);
    } catch (error) {
      console.error("❌ Error applying flash:", error);
    }
  }
} 