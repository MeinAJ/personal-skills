#!/usr/bin/env python3
"""
分析项目类型并推荐 Dockerfile 模板
"""

import os
import sys
import json
from pathlib import Path


def detect_project_type(project_path: str) -> dict:
    """检测项目类型"""
    path = Path(project_path)
    
    result = {
        "type": "unknown",
        "language": None,
        "framework": None,
        "recommendations": []
    }
    
    files = {f.name for f in path.iterdir() if f.is_file()}
    
    # 检测前端项目
    if "package.json" in files:
        package_json = path / "package.json"
        try:
            content = json.loads(package_json.read_text())
            deps = {**content.get("dependencies", {}), **content.get("devDependencies", {})}
            
            # 检测框架
            if "react" in deps:
                result["type"] = "frontend"
                result["language"] = "javascript"
                result["framework"] = "react"
                result["recommendations"].append("frontend-react.dockerfile")
            elif "vue" in deps:
                result["type"] = "frontend"
                result["language"] = "javascript"
                result["framework"] = "vue"
                result["recommendations"].append("frontend-react.dockerfile")
            elif "@angular/core" in deps:
                result["type"] = "frontend"
                result["language"] = "javascript"
                result["framework"] = "angular"
                result["recommendations"].append("frontend-react.dockerfile")
            
            # 检测后端
            elif "express" in deps:
                result["type"] = "backend"
                result["language"] = "javascript"
                result["framework"] = "express"
                result["recommendations"].append("backend-node.dockerfile")
            elif "@nestjs/core" in deps:
                result["type"] = "backend"
                result["language"] = "javascript"
                result["framework"] = "nestjs"
                result["recommendations"].append("backend-node.dockerfile")
                
        except Exception:
            pass
    
    # 检测 Python 项目
    elif "requirements.txt" in files or "pyproject.toml" in files:
        result["type"] = "backend"
        result["language"] = "python"
        
        req_file = path / "requirements.txt"
        if req_file.exists():
            content = req_file.read_text().lower()
            if "flask" in content:
                result["framework"] = "flask"
            elif "fastapi" in content:
                result["framework"] = "fastapi"
            elif "django" in content:
                result["framework"] = "django"
        
        result["recommendations"].append("backend-python.dockerfile")
    
    # 检测 Java 项目
    elif "pom.xml" in files or "build.gradle" in files:
        result["type"] = "backend"
        result["language"] = "java"
        result["framework"] = "spring" if "pom.xml" in files else "gradle"
        result["recommendations"].append("backend-java.dockerfile")
    
    # 检测 Go 项目
    elif "go.mod" in files:
        result["type"] = "backend"
        result["language"] = "go"
        result["recommendations"].append("backend-go.dockerfile")
    
    return result


def main():
    if len(sys.argv) < 2:
        project_path = "."
    else:
        project_path = sys.argv[1]
    
    result = detect_project_type(project_path)
    print(json.dumps(result, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
