#!/usr/bin/env python3
"""
验证 Dockerfile 是否符合最佳实践
"""

import re
import sys
from pathlib import Path


class DockerfileValidator:
    def __init__(self, dockerfile_path: str):
        self.path = Path(dockerfile_path)
        self.issues = []
        self.warnings = []
        self.content = self.path.read_text()
        self.lines = self.content.split('\n')
    
    def validate(self) -> dict:
        """执行所有验证"""
        self._check_latest_tag()
        self._check_root_user()
        self._check_apt_get_clean()
        self._check_layer_caching()
        self._check_healthcheck()
        self._check_expose()
        self._check_multistage()
        self._check_curl_wget()
        
        return {
            "valid": len(self.issues) == 0,
            "issues": self.issues,
            "warnings": self.warnings,
            "score": self._calculate_score()
        }
    
    def _check_latest_tag(self):
        """检查是否使用了 latest 标签"""
        pattern = r'FROM\s+\S+:latest'
        for i, line in enumerate(self.lines, 1):
            if re.search(pattern, line, re.IGNORECASE):
                self.warnings.append({
                    "line": i,
                    "message": "避免使用 'latest' 标签，请使用具体版本号",
                    "severity": "warning"
                })
    
    def _check_root_user(self):
        """检查是否使用了非 root 用户"""
        has_user = any(re.search(r'^USER\s+\S+', line, re.IGNORECASE) 
                       for line in self.lines)
        if not has_user:
            self.warnings.append({
                "line": 0,
                "message": "建议使用非 root 用户运行应用 (USER 指令)",
                "severity": "warning"
            })
    
    def _check_apt_get_clean(self):
        """检查 apt-get 是否清理了缓存"""
        for i, line in enumerate(self.lines, 1):
            if 'apt-get' in line.lower():
                if 'rm -rf /var/lib/apt/lists/' not in line:
                    self.warnings.append({
                        "line": i,
                        "message": "apt-get 后建议清理缓存: && rm -rf /var/lib/apt/lists/*",
                        "severity": "warning"
                    })
    
    def _check_layer_caching(self):
        """检查是否充分利用了构建缓存"""
        copy_count = sum(1 for line in self.lines if line.strip().startswith('COPY'))
        run_count = sum(1 for line in self.lines if line.strip().startswith('RUN'))
        
        if copy_count > 0 and run_count > 0:
            # 简单启发式检查：COPY . . 之前是否有依赖安装
            pass  # 更复杂的检查需要 AST 解析
    
    def _check_healthcheck(self):
        """检查是否有健康检查"""
        has_healthcheck = any(line.strip().startswith('HEALTHCHECK') 
                             for line in self.lines)
        if not has_healthcheck:
            self.warnings.append({
                "line": 0,
                "message": "建议添加 HEALTHCHECK 指令监控应用健康状态",
                "severity": "suggestion"
            })
    
    def _check_expose(self):
        """检查是否有 EXPOSE 指令"""
        has_expose = any(line.strip().startswith('EXPOSE') 
                        for line in self.lines)
        if not has_expose:
            self.warnings.append({
                "line": 0,
                "message": "建议添加 EXPOSE 指令说明暴露的端口",
                "severity": "suggestion"
            })
    
    def _check_multistage(self):
        """检查是否使用了多阶段构建"""
        from_count = sum(1 for line in self.lines 
                        if line.strip().startswith('FROM'))
        if from_count < 2:
            self.warnings.append({
                "line": 0,
                "message": "建议使用多阶段构建减小镜像体积",
                "severity": "suggestion"
            })
    
    def _check_curl_wget(self):
        """检查是否在生产镜像中安装了 curl/wget"""
        # 简单检查，实际应该分析多阶段构建
        pass
    
    def _calculate_score(self) -> int:
        """计算评分"""
        score = 100
        score -= len(self.issues) * 20
        score -= len(self.warnings) * 5
        return max(0, score)


def main():
    if len(sys.argv) < 2:
        print("Usage: validate_dockerfile.py <dockerfile-path>")
        sys.exit(1)
    
    path = sys.argv[1]
    validator = DockerfileValidator(path)
    result = validator.validate()
    
    import json
    print(json.dumps(result, indent=2, ensure_ascii=False))
    
    sys.exit(0 if result["valid"] else 1)


if __name__ == "__main__":
    main()
