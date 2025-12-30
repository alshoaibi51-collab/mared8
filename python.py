# compatibility_algorithm.py
import numpy as np
from typing import Dict, List
from dataclasses import dataclass

@dataclass
class UserProfile:
    id: int
    demographic: Dict
    religious: Dict
    cultural: Dict
    lifestyle: Dict
    preferences: Dict

class CompatibilityEngine:
    def __init__(self):
        self.weights = {
            'religious': 0.35,
            'cultural': 0.25,
            'lifestyle': 0.20,
            'preferences': 0.20
        }
    
    def calculate_compatibility(self, user1: UserProfile, user2: UserProfile) -> Dict:
        """
        حساب درجة التوافق بين مستخدمين
        """
        scores = {}
        
        # 1. التوافق الديني
        scores['religious'] = self._religious_compatibility(
            user1.religious, user2.religious
        )
        
        # 2. التوافق الثقافي
        scores['cultural'] = self._cultural_compatibility(
            user1.cultural, user2.cultural
        )
        
        # 3. التوافق في نمط الحياة
        scores['lifestyle'] = self._lifestyle_compatibility(
            user1.lifestyle, user2.lifestyle
        )
        
        # 4. تحقيق توقعات الشريك
        scores['preferences'] = self._preferences_compatibility(
            user1, user2
        )
        
        # 5. احتساب النتيجة الإجمالية
        overall_score = sum(
            scores[category] * self.weights[category]
            for category in self.weights
        )
        
        return {
            'overall_score': round(overall_score, 2),
            'detailed_scores': scores,
            'match_strengths': self._identify_strengths(scores),
            'match_concerns': self._identify_concerns(user1, user2)
        }
    
    def _religious_compatibility(self, rel1: Dict, rel2: Dict) -> float:
        """
        خوارزمية التوافق الديني
        """
        score = 0.0
        factors = {
            'faith_level': 0.3,
            'prayer_status': 0.25,
            'fasting': 0.2,
            'quran_knowledge': 0.15,
            'accepts_other_sects': 0.1
        }
        
        # مقارنة مستويات الالتزام
        faith_levels = {'ملتزم جدا': 100, 'ملتزم': 75, 'متوسط': 50, 'غير ملتزم': 25}
        if rel1.get('faith_level') and rel2.get('faith_level'):
            diff = abs(faith_levels.get(rel1['faith_level'], 50) - 
                      faith_levels.get(rel2['faith_level'], 50))
            score += (100 - diff) * factors['faith_level']
        
        # ... المزيد من المعايير الدينية
        
        return min(score, 100)
    
    def _preferences_compatibility(self, user1: UserProfile, user2: UserProfile) -> float:
        """
        تحقق من تحقيق توقعات كل شريك
        """
        score = 0.0
        
        # تحقق من توقعات user1 تجاه user2
        score += self._check_user_preferences(user1.preferences, user2)
        
        # تحقق من توقعات user2 تجاه user1
        score += self._check_user_preferences(user2.preferences, user1)
        
        return score / 2
    
    def _check_user_preferences(self, preferences: Dict, partner: UserProfile) -> float:
        """
        تحقق إذا كان الشريك يلبي توقعات المستخدم
        """
        points = 0
        total_points = 0
        
        # تحقق العمر
        if preferences.get('min_age') and partner.demographic.get('age'):
            if preferences['min_age'] <= partner.demographic['age'] <= preferences.get('max_age', 100):
                points += 1
            total_points += 1
        
        # تحقق التعليم
        if preferences.get('min_education_level'):
            # ... منطق المقارنة
            pass
        
        # ... معايير أخرى
        
        return (points / max(total_points, 1)) * 100
    
    def find_matches(self, user: UserProfile, pool: List[UserProfile], limit: int = 10) -> List[Dict]:
        """
        البحث عن أفضل التوافقات للمستخدم
        """
        matches = []
        
        for potential_match in pool:
            # فلتر أولي سريع
            if self._quick_filter(user, potential_match):
                continue
            
            # حساب التوافق التفصيلي
            compatibility = self.calculate_compatibility(user, potential_match)
            
            if compatibility['overall_score'] >= 60:  # عتبة التوافق
                matches.append({
                    'user': potential_match,
                    'compatibility': compatibility
                })
        
        # ترتيب حسب أفضل التوافقات
        matches.sort(key=lambda x: x['compatibility']['overall_score'], reverse=True)
        
        return matches[:limit]