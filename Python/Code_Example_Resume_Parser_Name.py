import os
import PyPDF2
import re
import spacy
import pandas as pd
from collections import defaultdict

# Load English tokenizer, tagger, parser and NER
nlp = spacy.load("en_core_web_sm")

class NameExtractor:
    def __init__(self, pdf_path):
        self.pdf_path = pdf_path
        self.text = self._extract_text()
        self.name = self._parse_name()
        
    def _extract_text(self):
        """Extract text from PDF file"""
        text = ''
        with open(self.pdf_path, 'rb') as file:
            reader = PyPDF2.PdfReader(file)
            for page in reader.pages:
                page_text = page.extract_text()
                if page_text:
                    # Clean up text
                    page_text = re.sub(r'\s+', ' ', page_text)
                    page_text = re.sub(r'(?<!\n)\n(?!\n)', ' ', page_text)
                    text += page_text + '\n'
        return text.strip()
    
    def _parse_name(self):
        """Extract name using advanced patterns and NER"""
        # Try to find name at the start of the text
        first_line = self.text.split('\n')[0]
        
        # List of common non-name phrases to exclude
        non_name_phrases = [
            'curriculum vitae', 'resume', 'cv', 'educational background',
            'professional experience', 'contact information', 'personal details',
            'work experience', 'education', 'skills', 'references', 'objective',
            'summary', 'profile', 'career objective', 'personal profile'
        ]
        
        # Improved patterns for Chinese and Western names with better validation
        patterns = [
            # Chinese name patterns with length validation
            r'^([A-Z]{2,} [A-Z][a-z]{2,})\b',  # SHI Haoliang
            r'^([A-Z][a-z]{2,} [A-Z][a-z]{2,})\b',  # Haoliang Shi
            r'^([A-Z][a-z]{2,} [A-Z]{2,})\b',  # Haoliang SHI
            r'^([A-Z]{2,} [A-Z]{2,})\b',  # SHI HAOLIANG
            r'^([A-Z][a-z]{2,} [A-Z][a-z]{2,} [A-Z][a-z]{2,})\b',  # Three character names
        ]
        
        # Check if first line matches any patterns and isn't a non-name phrase
        for pattern in patterns:
            match = re.match(pattern, first_line)
            if match and not any(phrase in first_line.lower() for phrase in non_name_phrases):
                return match.group(1)
        
        # If no match found, use spaCy NER as fallback
        doc = nlp(first_line)
        for ent in doc.ents:
            if ent.label_ == 'PERSON':
                return ent.text
                
        return None
